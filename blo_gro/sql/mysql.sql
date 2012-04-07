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
    PARTITION p201203 VALUES LESS THAN ( TO_DAYS('2012-04-01') ) COMMENT '2012-04-01' ENGINE = InnoDB,
    PARTITION p201204 VALUES LESS THAN ( TO_DAYS('2012-05-01') ) COMMENT '2012-05-01' ENGINE = InnoDB,
    PARTITION p201205 VALUES LESS THAN ( TO_DAYS('2012-06-01') ) COMMENT '2012-06-01' ENGINE = InnoDB,
    PARTITION p201206 VALUES LESS THAN ( TO_DAYS('2012-07-01') ) COMMENT '2012-07-01' ENGINE = InnoDB,
    PARTITION p201207 VALUES LESS THAN ( TO_DAYS('2012-08-01') ) COMMENT '2012-08-01' ENGINE = InnoDB,
    PARTITION p201208 VALUES LESS THAN ( TO_DAYS('2012-09-01') ) COMMENT '2012-09-01' ENGINE = InnoDB
);
