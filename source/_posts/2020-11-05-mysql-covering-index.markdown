---
layout: post
title: "mysql_covering_index"
date: 2020-11-05 11:37:02 +0800
comments: true
categories: mysql
keywords: mysql index transaction covering index
description: mysql covering index
---

## index
索引用于快速查找具有特定列值的行，如果没有索引，mysql必须从第一行开始，扫描全表找到对应的行。表越大，花费越多。如果表中有相关的索引，mysql可以快速确定要在数据文件中查找的位置。大多数mysql索引（primary key，unique，index和fulltext）存储在B-trees。空间数据类型的索引使用R-trees；MEMORY表还支持hash indexes；InnoDB对fulltext使用倒排表。<br>
MySQL使用索引进行以下操作：
<!--more-->
- 通过where条件快速查询。
- 最优匹配。如果可以在多个索引之间进行选择，则MySQL通常会使用查找最小行数的索引。
- 如果表具有多列索引，那么优化器可以使用索引的任何最左前缀来查找行。举例来说，如果你有一个三列的索引 (col1, col2, col3)，你可以索引的搜索有(col1)， (col1, col2)以及(col1, col2, col3)。
- 执行联接时从其他表中检索行。如果声明相同的类型和大小，MySQL可以更有效地在列上使用索引。在这种情况下， VARCHAR与 CHAR被认为是相同的，如果它们被声明为相同的大小。例如， VARCHAR(10)和 CHAR(10)是相同的大小，但是 VARCHAR(10)和 CHAR(15)不是。<br>
    对于非二进制字符串列之间的比较，两个列应使用相同的字符集，不同的字符集将导致索引失效。例如，将utf8列与latin1列进行比较会排除使用索引。<br>
    如果不能不通过转换直接比较值，则比较不同的列（例如，将字符串列与时间或数字列进行比较）可能会阻止使用索引。对于给定的值，如数值列的值为1，它可能比较等于在字符串列，例如任何数量的值 '1'，' 1'， '00001'，或'01.e1'，导致索引失效。
- 在索引列使用MIN()或 MAX()。mysql预处理器将进行优化，预处理器会检查您是否正在索引出现的所有关键部分上使用。在这种情况下，MySQL为每个表达式执行一次键查找，并将其替换为常量，所有表达式都用常量替换完成后，查询将立即返回。
- 排序或分组查询（order by， group by）使用最左匹配索引（order by key1, key2）；如果倒序排序（order by key1, key2 desc）,将按相反顺序使用索引key。
- 某些情况下，mysql会直接从索引中获取数据，而不用查询表；例如：只查询索引列数据。注意：当开启列长事务时，可能导致该优化失效，回表查询。
- 当全表扫描快于走索引查询时，mysql也不会走索引。

## covering index
查询的所有列都包含在索引中时，mysql不会扫描表（即不会回表查询），这种情况mysql定义为covering index；InnoDb引擎下，开启事务时，将不会使用这种优化查询。

## 参考资料
[8.5.2 Optimizing InnoDB Transaction Management](https://dev.mysql.com/doc/refman/8.0/en/optimizing-innodb-transaction-management.html)

