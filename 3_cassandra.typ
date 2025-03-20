#import "template/template.typ": *

#show: project.with(
  title: "Отчёт по практической работе №3",
  theme: "Знакомство с Tombstone в Apache Cassandra",
  department: "Математического обеспечения и стандартизации информационных технологий",
  course: "Распределенные системы управления базами данных",
  authors: (
    "Буренин А. А.",
  ),
  lecturer: "Красников С. А.",
  group: "ИКБО-07-22",
  date: datetime.today(),
  add_toc: false,
)

= Ход работы

== Кластер Apache Cassandra

В работе будет использоваться кластер из трёх нод, созданный в предыдущей работе.

== Утилита sstabledump и ее установка
Для устнановки утилиты sstabledump подключимся к ноде и установим утилиту из внешнего репозитория. Результат можно увидеть на #ref(<install_sstabledump>, supplement: "рисунке").

#picture(
  path: "img/3/install_sstabledump.png",
  caption: "Успешно утановлен пакет cassandra-tools, частью которого является sstabledump",
) <install_sstabledump>

== Создание keyspace и таблиц
Для заполнения данных был использован скрпит, предоставленый в методических указаниях.

#listing(
  caption: "Код для создания тестовых данных",
  body: raw("
CREATE KEYSPACE cycling WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'} AND durable_writes = true;

CREATE TABLE cycling.rank_by_year_and_name (
  race_year int,
  race_name text,
  rank int,
  cyclist_name text,
  PRIMARY KEY ((race_year, race_name), rank)
) WITH CLUSTERING ORDER BY (rank ASC);

INSERT INTO cycling.rank_by_year_and_name (race_year, race_name, cyclist_name, rank) 
VALUES (2015, 'Tour of Japan - Stage 4 - Minami > Shinshu', 'Benjamin PRADES', 1);

INSERT INTO cycling.rank_by_year_and_name (race_year, race_name, cyclist_name, rank)
VALUES (2015, 'Tour of Japan - Stage 4 - Minami > Shinshu', 'Adam PHELAN', 2);

INSERT INTO cycling.rank_by_year_and_name (race_year, race_name, cyclist_name, rank) 
VALUES (2015, 'Tour of Japan - Stage 4 - Minami > Shinshu', 'Thomas LEBAS', 3);

INSERT INTO cycling.rank_by_year_and_name (race_year, race_name, cyclist_name, rank) 
VALUES (2015, 'Giro d''Italia - Stage 11 - Forli > Imola', 'Ilnur ZAKARIN', 1);

INSERT INTO cycling.rank_by_year_and_name (race_year, race_name, cyclist_name,
rank) VALUES (2015, 'Giro d''Italia - Stage 11 - Forli > Imola', 'Carlos BETANCUR', 2);
INSERT INTO cycling.rank_by_year_and_name (race_year, race_name, cyclist_name,
rank) VALUES (2014, '4th Tour of Beijing', 'Phillippe GILBERT', 1);
INSERT INTO cycling.rank_by_year_and_name (race_year, race_name, cyclist_name,
rank) VALUES (2014, '4th Tour of Beijing', 'Daniel MARTIN', 2);
INSERT INTO cycling.rank_by_year_and_name (race_year, race_name, cyclist_name,
rank) VALUES (2014, '4th Tour of Beijing', 'Johan Esteban CHAVES', 3);

CREATE TABLE cycling.cyclist_career_teams (
  id UUID PRIMARY KEY,
  lastname text,
  teams set<text>
);

CREATE TABLE cycling.calendar (
  race_id int,
  race_name text,
  race_start_date timestamp,
  race_end_date timestamp,
  PRIMARY KEY (race_id, race_start_date, race_end_date)
);

"),
)

Результат выполнения этого скрипта можно увидеть на #ref(<create_tables>, supplement: "рисунке")

#picture(
  path: "img/3/insert_data.png",
  caption: "Данные вставленные в базу данных"
) <create_tables>

== Выгрузка SSTable

Для выгрузки данных из sstable можно воспользоваться утилитой sstabledump.

#picture(
  path: "img/3/sstabledump.png",
  caption: "Дамп таблицы rank_by_year_and_name",
  width: 65%
)

==	Tombstone для разделов

После выполнения команды для удалении партиции, представленной на #ref(<del_part_list>, supplement: "листинге"), и флаша изменений на диск. Появился новыый файл, содержимое которого предствалено на #ref(<del_part_img>, supplement: "рисунке").

#listing(
  body: raw("DELETE from cycling.rank_by_year_and_name WHERE race_year = 2014 AND race_name = '4th Tour of Beijing';"),
  caption: "Команда для удаления партиции"
) <del_part_list>

#picture(
  path: "img/3/del_part.png",
  caption: "Tombstone для партиции"
) <del_part_img>

== Tombstone для строк

После выполнения запроса на удаление строки, представленного на #ref(<del_row_list>, supplement: "листинге"), и флаша изменений на диск. Появился новыый файл, содержимое которого предствалено на #ref(<del_row_img>, supplement: "рисунке").

#listing(
  body: raw("DELETE from cycling.rank_by_year_and_name WHERE race_year = 2015
AND race name = 'Giro d''Italia - Stage 11	- Forli > Imola' AND rank = 2;
"),
  caption: "Команда для удаления партиции"
) <del_row_list>

#picture(
  path: "img/3/del_row.png",
  caption: "Tombstone для строки",
  width: 90%
) <del_row_img>

== 
= Контрольные вопросы

*Какая опция для таблицы устанавливает срок чтения удаленных
данных?*

В Apache Cassandra срок чтения удаленных данных определяет опция gc_grace_seconds, по умолчанию оно десять дней. Эту опцию не следует делать слишком маленькой, так как удаление tombstone удаляется до срока, может привести к появлению "зомби"-данных (удаленные данные могут снова появиться при репликации).

*В чем заключается стратегия разрешения конфликтов last-write-win?*

При использовании этой стратегии финальной версией записи будет та, которая была добавлена последней.

*Назвать 3 варианта применения tombstone.*

+ *Удаление данных*:
  + Когда выполняется операция DELETE, Cassandra не удаляет данные физически сразу. Вместо этого она создает tombstone, который помечает данные как удаленные.
  + Tombstone используется для синхронизации удаленных данных между узлами кластера.
+ *Истечение срока действия TTL*:
  + Если для данных установлен TTL (время жизни), по истечении этого срока Cassandra создает tombstone, чтобы пометить данные как удаленные.
  + Это позволяет Cassandra корректно обрабатывать удаление данных с истекшим TTL.
+ *Обработка конфликтов при репликации*:
  + В распределенной системе данные могут быть изменены на разных узлах одновременно. Tombstone помогает разрешить конфликты, указывая, что данные были удалены на одном из узлов.

= Вывод
В настоящей работе был проведён анализ работы с Apache Cassandra. Изучены ключевые концепции, такие как TTL (Time-to-Live), который задаёт срок жизни данных, и tombstones — маркеры для обозначения удалённых данных, обеспечивающие согласованность в распределённой системе. Была проведена настройка кластера Cassandra с использованием Docker, создание пространства ключей `cycling` и таблиц (`rank_by_year_and_name`, `cyclist_career_teams`, `calendar`). Проведены операции вставки, обновления и удаления данных с использованием TTL и tombstone, а также анализ структуры данных через утилиту `sstabledump`. Работа продемонстрировала, что Cassandra является мощным инструментом для построения масштабируемых и надёжных распределённых систем.
