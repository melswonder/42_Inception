#!/bin/bash

set -e

# Read passwords from secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Installing database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# 一時的にMariaDBを起動
echo "Starting MariaDB for initialization..."
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --skip-grant-tables &
MYSQL_PID=$!

# MariaDBの起動を待つ
echo "Waiting for MariaDB to start..."
for i in {30..0}; do
    if mysqladmin ping --silent 2>/dev/null; then
        break
    fi
    echo "MariaDB is starting... $i"
    sleep 1
done

if [ "$i" = 0 ]; then
    echo "MariaDB failed to start"
    exit 1
fi

echo "MariaDB started successfully"

# データベースとユーザーが既に存在するかチェック
if ! mysql -e "USE ${MYSQL_DATABASE};" 2>/dev/null; then
    echo "Initializing database..."

    mysql <<EOF
FLUSH PRIVILEGES;
-- Rootパスワードを設定
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
-- 匿名ユーザーを削除
DELETE FROM mysql.user WHERE User='';
-- リモートからのroot接続を無効化
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
-- testデータベースを削除
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- WordPressデータベースとユーザーを作成
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo "Database initialized successfully"
else
    echo "Database already initialized"
fi

# 一時MariaDBをシャットダウン
echo "Shutting down temporary MariaDB..."
kill $MYSQL_PID
wait $MYSQL_PID 2>/dev/null || true

# 本番用にMariaDBを起動（フォアグラウンド）
echo "Starting MariaDB in production mode..."
exec mysqld --user=mysql --datadir=/var/lib/mysql