/*
--- @auth
認証情報を保存するテーブル。
BloGroは外部サービスを経由して利用するので、
そのIDとauthorIDを紐付け出来るようにする必要がある。

SELECT * FROM auth WHERE service_name = 'facebook' AND service_id = '100532035250';
みたいなクエリを想定している。
*/
CREATE TABLE `auth` (
    id                INTEGER      UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    service_name      VARCHAR(64)  BINARY   NOT NULL COMMENT 'ログインで使用するサービスの名前',
    service_id        VARCHAR(64)  BINARY   NOT NULL COMMENT 'サービス内で固有のID',
    author_id         INTEGER      UNSIGNED NOT NULL COMMENT 'id for `author`',
    created_at        DATETIME              NOT NULL,
    updated_at        TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY service_login_idx (service_name, service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='認証情報';

/*
--- @author
記事を書く人。
投稿時にセレクトボックスを出したり、
サイドバーに書いた人と投稿数を出す用。

SELECT * FROM author WHERE id = ?;
みたいなクエリを想定している。
*/
CREATE TABLE `author` (
    id                INTEGER      UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    author            VARCHAR(64)  BINARY   NOT NULL COMMENT '記事を書いた人',
    created_at        DATETIME              NOT NULL,
    updated_at        TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='記事を書く人';

/*
--- @author_profile
記事を書く人のプロフィール用。
必要になる場面は少ないと思うので別テーブル。

SELECT * FROM author_profile WHERE author_id = ?;
みたいなクエリを想定している。
*/
CREATE TABLE `author_profile` (
    author_id         INTEGER      UNSIGNED NOT NULL PRIMARY KEY COMMENT 'id from `author`',
    misc_data         TEXT         BINARY   NOT NULL COMMENT 'プロフィール情報'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='プロフィール';

/*
--- @article
全文検索を利用する為、実際の記事の内容はGroongaに入れる。
このtableにINSERT INTOしたあと、last_insert_idを取ってきてそれを主キーとしてGroongaにタイトル、本文、タグ情報を入れる。

idでユーザーが記事にアクセスし、それに紐付くidをもとにGroongaから実際のデータをfetchする。

indexは
SELECT * FROM article WHERE id = ?;
SELECT * FROM article WHERE status = 'public' AND published_at BETWEEN ? AND ?;
みたいなクエリを想定している。
*/
CREATE TABLE `article` (
    id                INTEGER      UNSIGNED NOT NULL AUTO_INCREMENT,
    author_id         INTEGER      UNSIGNED NOT NULL COMMENT '記事を書いた人 id from `author`',
    status            ENUM('private', 'public') NOT NULL DEFAULT 'private',
    published_at      DATETIME              NOT NULL COMMENT "公開日",
    created_at        DATETIME              NOT NULL,
    updated_at        TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id, published_at),
    INDEX      author_idx (author_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='記事'
  PARTITION BY RANGE( TO_DAYS(published_at) ) (
    PARTITION p2012 VALUES LESS THAN ( TO_DAYS('2012-01-01') ) COMMENT '2012' ENGINE = InnoDB,
    PARTITION p2013 VALUES LESS THAN ( TO_DAYS('2013-01-01') ) COMMENT '2013' ENGINE = InnoDB,
    PARTITION p2014 VALUES LESS THAN ( TO_DAYS('2014-01-01') ) COMMENT '2014' ENGINE = InnoDB,
    PARTITION p2015 VALUES LESS THAN ( TO_DAYS('2015-01-01') ) COMMENT '2015' ENGINE = InnoDB,
    PARTITION p2016 VALUES LESS THAN ( TO_DAYS('2016-01-01') ) COMMENT '2016' ENGINE = InnoDB,
    PARTITION p2017 VALUES LESS THAN ( TO_DAYS('2017-01-01') ) COMMENT '2017' ENGINE = InnoDB
);
