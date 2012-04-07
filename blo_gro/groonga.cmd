table_create  --name  article --flags TABLE_HASH_KEY --key_type UInt32
column_create --table article --name title --flags COLUMN_SCALAR --type ShortText
column_create --table article --name body --flags COLUMN_SCALAR --type LongText
column_create --table article --name tags --flags COLUMN_VECTOR --type ShortText
table_create  --name  article_terms --flags TABLE_PAT_KEY|KEY_NORMALIZE --key_type ShortText --default_tokenizer TokenBigram
column_create --table article_terms --name title --flags COLUMN_INDEX|WITH_POSITION --type article --source title
column_create --table article_terms --name body  --flags COLUMN_INDEX|WITH_POSITION --type article --source body
column_create --table article_terms --name tags  --flags COLUMN_INDEX|WITH_POSITION --type article --source tags
