#import "template/template.typ": *

#show: project.with(
  title: "Отчёт по практической работе №1",
  theme: "Знакомство с Apache Cassandra",
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

#picture(
  path: "img/1/start_container.png",
  caption: "Запуск Cassandra в контейнере",
)

#picture(
  path: "img/1/chech_sql.png",
  caption: "Подключение к Cassandra через cqlsh",
)

#picture(
  path: "img/1/describe.png",
  caption: "Выполнение команд DESCRIBE",
)

#picture(
  path: "img/1/create_keyspace.png",
  caption: "Создание нового keyspace",
)

#picture(
  path: "img/1/create_table.png",
  caption: "Создание таблицы user и вставка записи в нее",
)

#picture(
  path: "img/1/delete_column.png",
  caption: "Удаление значения из колонки last_name",
)

#picture(
  path: "img/1/delete_row.png",
  caption: "Удаление строки из таблицы user",
)

#picture(
  path: "img/1/drop_table.png",
  caption: "Очистка и удаление таблицы user",
)