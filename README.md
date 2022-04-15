# Моделирование изменений балансов уроков у студентов языковой онлайн-школы.

Проект выполнен в рамках обучения на курсе SkyPro "Аналитик данных". 

Ссылка на курс: https://sky.pro/courses/analytics/data_analytics

Подробнее о модуле по SQL: https://sky.pro/courses/analytics/sql

# Задачи по проекту:
- смоделировать изменение балансов студентов;
- понять, сколько всего уроков было на балансе каждого из всех учеников за каждый календарный день;
- найти аномалии в данных, составить список вопросов дата-инженерам и владельцам таблиц;
- визуализировать, как это количество менялось под влиянием транзакций (оплат, начислений, корректирующих списаний) и уроков (списаний с баланса по мере прохождения уроков);
- сделать выводы на основе полученной визуализации.

# Выводы по проекту:
- в количестве купленных уроков наблюдается заметный разброс значений (график tansaction_balans_change). Особенно сильные выбросы наблюдаются в конце месяца и начале следующего. Это может быть связано со многими факторами, как, например, общая платежная политика школы, проведение каких-то маркетинговых акций, привлечение каких-то корпоративных клиентов, сезонность, и т.д. 
- общее количество уроков, покупаемых студентами школы, имеет стабильную тенденцию к увеличению (восходящую линию тренда) (график tansaction_balans_change_cs). Это может быть обусловлено активным развитием школы, т.е. привлечением новых клиентов, или хорошей конверсией учеников, или увеличением интенсивности, т.е. прохождением учениками большего количества уроков,  или совокупностью этих факторов;
- количество проходимых студентами уроков имеет меньший, чем их покупка, разброс значений (график classes). Количество пройденных уроков заметно больше в дни, приходящиеся на вторую половину недели, а их минимальные значения приходятся  в основном на воскресенья, из чего можно сделать вывод, что студенты не так охотно занимаются в выходные дни, особенно по воскресеньям, как в остальные дни недели.
- общая тенденция к увеличению количества пройденных уроков особенно заметна с начала учебного года, т.е. с сентября (график classes_cs), что можно объяснить, например, окончанием сезона отпусков.
- студенты в большинстве своем сначала оплачивают уроки, т.е. школа  сначала получает выручку, а потом их проходят (график balance: линейный, восходящий и имеет положительные значения) т.е. школа несет расходы уже после получения денег за их проведение (например, на оплату учителям, рекламу, аренду офиса и т.д.). Работая таким образом, школа постоянно имеет в запасе некую сумму денежных средств, что является положительным фактором. Нужно отметить также то, что количество уроков, которое школа "задолжала" своим студентам, увеличивается от месяца к месяцу, на основании чего можно сказать, что, вероятно, школа проводит политику предоплаты уроков и активно привлекает новых и/или удерживает старых учеников.
- школа активно развивается и увеличивает свою аудиторию, имея в наличии запас денежных средств.

# 1. Схема базы данных skyeng_db:
- students — данные о студентах (потенциальных, которые только оставили заявку, и тех, кто действительно оплатил обучение);
- orders — данные о заявках на обучение;
- classes — данные об уроках;
- payments — данные об оплатах;
- teachers — данные об учителях.

# 2. SQL-запрос с описанием логики его выполнения:
1. Узнаем, когда была первая транзакция для каждого студента. Начиная с этой даты, будем собирать его баланс уроков.
2. Соберем таблицу с датами за каждый календарный день 2016 года
3. Узнаем, за какие даты имеет смысл собирать баланс для каждого студента
4. Найдем изменения балансов студентов, связанные с успешными транзакциями
5. Найдем баланс студентов, который сформирован только транзакциями
6. Найдем изменения балансов студентов, связанные с прохождением уроков
7. Найдем баланс студентов, который сформирован только прохождением уроков
8. Найдем общий баланс студентов, сформированный транзакциями и прохождением уроков
9. Посмотрим, как менялось общее количество уроков на балансе всех студентов

# 3. Визуализация динамики изменений балансов уроков у студентов:
- transaction_balance_change - изменение общего баланса под влиянием транзакций (оплат, начислений, корректирующих списаний);
- transaction_balance_change_cs - кумулятивная сумма изменений общего баланса под влиянием транзакций;
- classes - изменение общего баланса под влиянием уроков (списаний с баланса по мере их прохождения);
- classes_cs - кумулятивная сумма изменений общего баланса под влиянием уроков;
- balance - общее количество уроков на балансе всех студентов.
