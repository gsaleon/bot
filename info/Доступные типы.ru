Доступные типы
https://tlgrm.ru/docs/bots/api#available-types

Bot API представляет из себя HTTP-интерфейс для работы с ботами в Telegram.
Примечание

Подробнее о том, как создать и настроить своего бота, читайте в статье с информацией для разработчиков.

    Список изменений
    Авторизация
    Отправка запросов
    Получение обновлений
    Доступные типы
    Доступные методы

Авторизация бота

Каждому боту при создании присваивается уникальный токен вида 123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11. В документации для простоты вместо него будет использоваться <token>. Подробнее о том, как получить или заменить токен для вашего бота, читайте в этой статье.
Отправка запросов

Все запросы к Telegram Bot API должны осуществляться через HTTPS в следующем виде: https://api.telegram.org/bot<token>/НАЗВАНИЕ_МЕТОДА. Например:

https://api.telegram.org/bot123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11/getMe

Допускаются GET и POST запросы. Для передачи параметров в Bot API доступны 4 способа:

    Запрос в URL
    application/x-www-form-urlencoded
    application/json (не подходит для загрузки файлов)
    multipart/form-data (для загрузки файлов)

Ответ придёт в виде JSON-объекта, в котором всегда будет булево поле ok и опциональное строковое поле description, содержащее человекочитаемое описание результата. Если поле ok истинно, то запрос прошёл успешно и результат его выполнения можно увидеть в поле result. В случае ошибки поле ok будет равно false, а причины ошибки будут описаны в поле description. Кроме того, в ответе будет целочисленное поле error_code, но коды ошибок будут изменены в будущем.
Предупреждение

Все методы регистрозависимы и должны быть в кодировке UTF-8.
Отправка запросов при получении обновления

Если ваш бот работает через вебхуки, то вы можете осуществить запрос к Bot API одновременно с отправкой ответа на вебхук. Для передачи параметров нужно использовать один из типов:

    application/json
    application/x-www-form-urlencoded
    multipart/form-data

Метод для вызова должен быть определён в запросе в поле method. Однако, имейте в виду: невозможно узнать статус и результат такого запроса.

    Примеры таких запросов описаны в FAQ.

Получение обновлений

Существует два диаметрально противоположных по логике способа получать обновления от вашего бота: getUpdates и вебхуки. Входящие обновления будут храниться на сервере до тех пор, пока вы их не обработаете, но не дольше 24 часов.

Независимо от способа получения обновлений, в ответ вы получите объект Update, сериализованный в JSON.
Update

Этот объект представляет из себя входящее обновление. Под обновлением подразумевается действие, совершённое с ботом — например, получение сообщения от пользователя.

Только один из необязательных параметров может присутствовать в каждом обновлении.
Поле 	Тип 	Описание
update_id 	Integer 	The update‘s unique identifier. Update identifiers start from a certain positive number and increase sequentially. This ID becomes especially handy if you’re using Webhooks, since it allows you to ignore repeated updates or to restore the correct update sequence, should they get out of order.
message 	Message 	Опционально. New incoming message of any kind — text, photo, sticker, etc.
inline_query 	InlineQuery 	Опционально. New incoming inline query
chosen_inline_result 	ChosenInlineResult 	Опционально. The result of an inline query that was chosen by a user and sent to their chat partner.
callback_query 	CallbackQuery 	Опционально. New incoming callback query
getUpdates

Этот метод используется для получения обновлений через long polling (wiki). Ответ возвращается в виде массива объектов Update.
Параметры 	Тип 	Обязательный 	Описание
offset 	Integer 	Необязательный 	Identifier of the first update to be returned. Must be greater by one than the highest among the identifiers of previously received updates. By default, updates starting with the earliest unconfirmed update are returned. An update is considered confirmed as soon as getUpdates is called with an offset higher than its update_id. The negative offset can be specified to retrieve updates starting from -offset update from the end of the updates queue. All previous updates will forgotten.
limit 	Integer 	Необязательный 	Limits the number of updates to be retrieved. Values between 1—100 are accepted. Defaults to 100.
timeout 	Integer 	Необязательный 	Timeout in seconds for long polling. Defaults to 0, i.e. usual short polling

    Примечание:

        Этот метод не будет работать, если у вас уже подключен webhook.
        Во избежания повторяющихся обновлений, рекомендуется высчитывать offset каждый раз заново.

setWebhook

Этот метод необходим для задания URL вебхука, на который бот будет отправлять обновления. Каждый раз при получении обновления на этот адрес будет отправлен HTTPS POST с сериализованным в JSON объектом Update. При неудачном запросе к вашему серверу попытка будет повторена умеренное число раз.

Для большей безопасности рекомендуется включить токен в URL вебхука, например, так: https://yourwebhookserver.com/<token>. Так как никто посторонний не знает вашего токена, вы можете быть уверены, что запросы к вашему вебхуку шлёт именно Telegram.
Параметры 	Тип 	Обязательный 	Описание
url 	String 	Нет 	HTTPS url для отправки запросов. Чтобы удалить вебхук, отправьте пустую строку.
certificate 	InputFile 	Нет 	Загрузка публичного ключа для проверки корневого сертификата. Подробнее в разделе про самоподписанные сертификаты.

    Примечание:

        При подключенном и настроенном вебхуке метод getUpdates не будет работать.
        При использовании самоподписанного сертификата, вам необходимо загрузить публичный ключ с помощью параметра certificate.
        На текущий момент отправка обновлений через вебхуки доступна только на эти порты: 443, 80, 88, 8443.

getWebhookInfo

Содержит информацию о текущем состоянии вебхука.
Поле 	Тип 	Описание
url 	String 	URL вебхука, может быть пустым
has_custom_certificate 	Boolean 	True, если вебхук использует самозаверенный сертификат
pending_update_count 	Integer 	Количество обновлений, ожидающих доставки
last_error_date 	Integer 	Опционально. Unix-время самой последней ошибки доставки обновления на указанный вебхук
last_error_message 	String 	Опционально. Описание в человекочитаемом формате последней ошибки доставки обновления на указанный вебхук
Доступные типы

Все типы, использующиеся в Bot API, являются JSON-объектами.

Для хранения всех полей типа Integer безопасно использовать 32-битные знаковые целые числа, если не указано иначе.

    Необязательные поля могут быть опущены в ответе, если они не относятся к ответу. 

User

Этот объект представляет бота или пользователя Telegram.
Поле 	Тип 	Описание
id 	Integer 	Уникальный идентификатор пользователя или бота
first_name 	String 	Имя бота или пользователя
last_name 	String 	Опционально. Фамилия бота или пользователя
username 	String 	Опционально. Username пользователя или бота
Chat

Этот объект представляет собой чат.
Поле 	Тип 	Описание
id 	Integer 	Уникальный идентификатор чата. Абсолютное значение не превышает 1e13
type 	Enum 	Тип чата: “private”, “group”, “supergroup” или “channel”
title 	String 	Опционально. Название, для каналов или групп
username 	String 	Опционально. Username, для чатов и некоторых каналов
first_name 	String 	Опционально. Имя собеседника в чате
last_name 	String 	Опционально. Фамилия собеседника в чате
all_members_are_administrators 	Boolean 	Опционально.True, если все участники чата являются администраторами
Message

Этот объект представляет собой сообщение.
Поле 	Тип 	Описание
message_id 	Integer 	Уникальный идентификатор сообщения
from 	User 	Опционально. Отправитель. Может быть пустым в каналах.
date 	Integer 	Дата отправки сообщения (Unix time)
chat 	Chat 	Диалог, в котором было отправлено сообщение
forward_from 	User 	Опционально. Для пересланных сообщений: отправитель оригинального сообщения
forward_date 	Integer 	Опционально. Для пересланных сообщений: дата отправки оригинального сообщения
reply_to_message 	Message 	Опционально. Для ответов: оригинальное сообщение. Note that the Message object in this field will not contain further reply_to_message fields even if it itself is a reply.
text 	String 	Опционально. Для текстовых сообщений: текст сообщения, 0-4096 символов
entities 	Массив из MessageEntity 	Опционально. Для текстовых сообщений: особые сущности в тексте сообщения.
audio 	Audio 	Опционально. Информация об аудиофайле
document 	Document 	Опционально. Информация о файле
photo 	Массив из PhotoSize 	Опционально. Доступные размеры фото
sticker 	Sticker 	Опционально. Информация о стикере
video 	Video 	Опционально. Информация о видеозаписи
voice 	Voice 	Опционально. Информация о голосовом сообщении
caption 	String 	Опционально. Подпись к файлу, фото или видео, 0-200 символов
contact 	Contact 	Опционально. Информация об отправленном контакте
location 	Location 	Опционально. Информация о местоположении
venue 	Venue 	Опционально. Информация о месте на карте
new_chat_member 	User 	Опционально. Информация о пользователе, добавленном в группу
left_chat_member 	User 	Опционально. Информация о пользователе, удалённом из группы
new_chat_title 	String 	Опционально. Название группы было изменено на это поле
new_chat_photo 	Массив из PhotoSize 	Опционально. Фото группы было изменено на это поле
delete_chat_photo 	True 	Опционально. Сервисное сообщение: фото группы было удалено
group_chat_created 	True 	Опционально. Сервисное сообщение: группа создана
supergroup_chat_created 	True 	Опционально. Сервисное сообщение: супергруппа создана
channel_chat_created 	True 	Опционально. Сервисное сообщение: канал создан
migrate_to_chat_id 	Integer 	Опционально. Группа была преобразована в супергруппу с указанным идентификатором. Не превышает 1e13
migrate_from_chat_id 	Integer 	Опционально. Cупергруппа была создана из группы с указанным идентификатором. Не превышает 1e13
pinned_message 	Message 	Опционально. Указанное сообщение было прикреплено. Note that the Message object in this field will not contain further reply_to_message fields even if it is itself a reply.
MessageEntity

Этот объект представляет одну из особых сущностей в текстовом сообщении. Например: хештеги, имена пользователей, ссылки итд.
Поле 	Тип 	Описание
type 	String 	Type of the entity. One of mention (@username), hashtag, bot_command, url, email, bold (bold text), italic (italic text), code (monowidth string), pre (monowidth block), text_link (for clickable text URLs)
offset 	Integer 	Offset in UTF-16 code units to the start of the entity
length 	Integer 	Length of the entity in UTF-16 code units
url 	String 	Опционально. For “text_link” only, url that will be opened after user taps on the text
PhotoSize

Этот объект представляет изображение определённого размера или превью файла / стикера.
Поле 	Тип 	Описание
file_id 	String 	Уникальный идентификатор файла
width 	Integer 	Photo width
height 	Integer 	Photo height
file_size 	Integer 	Опционально. Размер файла
Audio

Этот объект представляет аудиозапись, которую клиенты Telegram воспинимают как музыкальный трек.
Поле 	Тип 	Описание
file_id 	String 	Уникальный идентификатор файла
duration 	Integer 	Duration of the audio in seconds as defined by sender
performer 	String 	Опционально. Performer of the audio as defined by sender or by audio tags
title 	String 	Опционально. Title of the audio as defined by sender or by audio tags
mime_type 	String 	Опционально. MIME файла, заданный отправителем
file_size 	Integer 	Опционально. Размер файла
Document

Этот объект представляет файл, не являющийся фотографией, голосовым сообщением или аудиозаписью.
Поле 	Тип 	Описание
file_id 	String 	Unique file identifier
thumb 	PhotoSize 	Опционально. Document thumbnail as defined by sender
file_name 	String 	Опционально. Original filename as defined by sender
mime_type 	String 	Опционально. MIME файла, заданный отправителем
file_size 	Integer 	Опционально. Размер файла
Sticker

Этот объект представляет стикер.
Поле 	Тип 	Описание
file_id 	String 	Уникальный идентификатор файла
width 	Integer 	Ширина стикера
height 	Integer 	Высота стикера
thumb 	PhotoSize 	Опционально. Превью стикера в формате .webp или .jpg
file_size 	Integer 	Опционально. Размер файла
Video

Этот объект представляет видеозапись.
Поле 	Тип 	Описание
file_id 	String 	Уникальный идентификатор файла
width 	Integer 	Ширина видео, заданная отправителем
height 	Integer 	Высота видео, заданная отправителем
duration 	Integer 	Продолжительность видео, заданная отправителем
thumb 	PhotoSize 	Опционально. Превью видео
mime_type 	String 	Опционально. MIME файла, заданный отправителем
file_size 	Integer 	Опционально. Размер файла
Voice

Этот объект представляет голосовое сообщение.
Поле 	Тип 	Описание
file_id 	String 	Уникальный идентификатор файла
duration 	Integer 	Продолжительность аудиофайла, заданная отправителем
mime_type 	String 	Опционально. MIME-тип файла, заданный отправителем
file_size 	Integer 	Опционально. Размер файла
Contact

Этот объект представляет контакт с номером телефона.
Поле 	Тип 	Описание
phone_number 	String 	Номер телефона
first_name 	String 	Имя
last_name 	String 	Опционально. Фамилия
user_id 	Integer 	Опционально. Идентификатор пользователя в Telegram
Location

Этот объект представляет точку на карте.
Поле 	Тип 	Описание
longitude 	Float 	Долгота, заданная отправителем
latitude 	Float 	Широта, заданная отправителем
Venue

Этот объект представляет объект на карте.
Поле 	Тип 	Описание
location 	Location 	Координаты объекта
title 	String 	Название объекта
address 	String 	Адрес объекта
foursquare_id 	String 	Опционально. Идентификатор объекта в Foursquare
UserProfilePhotos

Этот объект содержит фотографии профиля пользователя.
Поле 	Тип 	Описание
total_count 	Integer 	Общее число доступных фотографий профиля
photos 	Массив массивов с объектами PhotoSize 	Запрошенные изображения, каждое в 4 разных размерах.
File

Этот объект представляет файл, готовый к загрузке. Он может быть скачан по ссылке вида https://api.telegram.org/file/bot<token>/<file_path>. Ссылка будет действительна как минимум в течение 1 часа. По истечении этого срока она может быть запрошена заново с помощью метода getFile.

    Максимальный размер файла для скачивания — 20 МБ 

Поле 	Тип 	Описание
file_id 	String 	Уникальный идентификатор файла
file_size 	Integer 	Опционально. Размер файла, если известен
file_path 	String 	Опционально. Расположение файла. Для скачивания воспользуйтейсь ссылкой вида https://api.telegram.org/file/bot<token>/<file_path>
ReplyKeyboardMarkup

Этот объект представляет клавиатуру с опциями ответа (см. описание ботов).
Поле 	Тип 	Описание
keyboard 	Массив массивов с KeyboardButton 	Массив рядов кнопок, каждый из которых является массивом объектов KeyboardButton
resize_keyboard 	Boolean 	Опционально. Указывает клиенту подогнать высоту клавиатуры под количество кнопок (сделать её меньше, если кнопок мало). По умолчанию False, то есть клавиатура всегда такого же размера, как и стандартная клавиатура устройства.
one_time_keyboard 	Boolean 	Опционально. Указывает клиенту скрыть клавиатуру после использования (после нажатия на кнопку). Её по-прежнему можно будет открыть через иконку в поле ввода сообщения. По умолчанию False.
selective 	Boolean 	Опционально. Этот параметр нужен, чтобы показывать клавиатуру только определённым пользователям. Цели: 1) пользователи, которые были @упомянуты в поле text объекта Message; 2) если сообщения бота является ответом (содержит поле reply_to_message_id), авторы этого сообщения.

Пример: Пользователь отправляет запрос на смену языка бота. Бот отправляет клавиатуру со списком языков, видимую только этому пользователю.
KeyboardButton

Этот объект представляет одну кнопку в клавиатуре ответа. Для обычных текстовых кнопок этот объект может быть заменён на строку, содержащую текст на кнопке.
Поле 	Тип 	Описание
text 	String 	Текст на кнопке. Если ни одно из опциональных полей не использовано, то при нажатии на кнопку этот текст будет отправлен боту как простое сообщение.
request_contact 	Boolean 	Опционально. Если значение True, то при нажатии на кнопку боту отправится контакт пользователя с его номером телефона. Доступно только в диалогах с ботом.
request_location 	Boolean 	Опционально. Если значение True, то при нажатии на кнопку боту отправится местоположение пользователя. Доступно только в диалогах с ботом.

    Внимание:
    Параметры request_contact и request_location будут работать только в версиях Telegram, выпущенных позже 9 апреля 2016 года. Более старые клиенты проигнорируют это поле. 

ReplyKeyboardHide

После получения сообщения с этим объектом, приложение Telegram свернёт клавиатуру бота и отобразит стандартную клавиатуру устройства (с буквами). По умолчанию клавиатуры бота отображаются до тех пор, пока не будет принудительно отправлена новая или скрыта старая клавиатура. Исключение составляют одноразовые клавиатуры, которые скрываются сразу после нажатия на какую-либо кнопку (см. ReplyKeyboardMarkup).
Поле 	Тип 	Описание
hide_keyboard 	Boolean 	Указание клиенту скрыть клавиатуру бота
selective 	Boolean 	Опционально. Используйте этот параметр, чтобы скрыть клавиатуру только у определённых пользователей. Цели: 1) пользователи, которые были @упомянуты в поле text объекта Message; 2) если сообщения бота является ответом (содержит поле reply_to_message_id), авторы этого сообщения.

Пример: Пользователь голосует в опросе, бот отправляет сообщение с подтверждением и скрывает клавиатуру у этого пользователя, в то время как у всех остальных клавиатура видна.
InlineKeyboardMarkup

Этот объект представляет встроенную клавиатуру, которая появляется под соответствующим сообщением.
Поле 	Тип 	Описание
inline_keyboard 	Массив массивов с InlineKeyboardButton 	Массив строк, каждая из которых является массивом объектов InlineKeyboardButton.

    Внимание:
    Эти параметры будут работать только в версиях Telegram, выпущенных позже 9 апреля 2016 года. Более старые клиенты покажут ошибку вместо сообщения. 

InlineKeyboardButton

Этот объект представляет одну кнопку встроенной клавиатуры. Вы обязательно должны задействовать ровно одно опциональное поле.
Поле 	Тип 	Описание
text 	String 	Текст на кнопке
url 	String 	Опционально. URL, который откроется при нажатии на кнопку
callback_data 	String 	Опционально. Данные, которые будут отправлены в callback_query при нажатии на кнопку
switch_inline_query 	String 	Опционально. Если этот параметр задан, то при нажатии на кнопку приложение предложит пользователю выбрать любой чат, откроет его и вставит в поле ввода сообщения юзернейм бота и определённый запрос для встроенного режима. Если отправлять пустое поле, то будет вставлен только юзернейм бота.

Примечание: это нужно для того, чтобы быстро переключаться между диалогом с ботом и встроенным режимом с этим же ботом. Особенно полезно в сочетаниями с действиями switch_pm… – в этом случае пользователь вернётся в исходный чат автоматически, без ручного выбора из списка.
switch_inline_query_current_chat 	String 	Опционально. If set, pressing the button will insert the bot‘s username and the specified inline query in the current chat's input field. Can be empty, in which case only the bot’s username will be inserted.
callback_game 	CallbackGame 	Опционально. Description of the game that will be launched when the user presses the button.

NOTE: This type of button must always be the first button in the first row.

    Внимание:
    Эти параметры будут работать только в версиях Telegram, выпущенных позже 9 апреля 2016 года. Более старые клиенты покажут ошибку вместо сообщения. 

CallbackQuery

Этот объект представляет входящий запрос обратной связи от инлайн-кнопки с заданным callback_data.

Если кнопка, создавшая этот запрос, была привязана к сообщению, то в запросе будет присутствовать поле message.

Если кнопка была показана в сообщении, отправленном при помощи встроенного режима, в запросе будет присутствовать поле inline_message_id.
Поле 	Тип 	Описание
id 	String 	Уникальный идентификатор запроса
from 	User 	Отправитель
message 	Message 	Опционально. Сообщение, к которому была привязана вызвавшая запрос кнопка. Обратите внимание: если сообщение слишком старое, содержание сообщения и дата отправки будут недоступны.
inline_message_id 	String 	Опционально. Идентификатор сообщения, отправленного через вашего бота во встроенном режиме
data 	String 	Данные, связанные с кнопкой. Обратите внимание, что клиенты могут добавлять свои данные в это поле.
ForceReply

Upon receiving a message with this object, Telegram clients will display a reply interface to the user (act as if the user has selected the bot‘s message and tapped ’Reply'). This can be extremely useful if you want to create user-friendly step-by-step interfaces without having to sacrifice privacy mode.
Поле 	Тип 	Описание
force_reply 	True 	Shows reply interface to the user, as if they manually selected the bot‘s message and tapped ’Reply'
selective 	Boolean 	Опционально. Use this parameter if you want to force reply from specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot's message is a reply (has reply_to_message_id), sender of the original message.

    Пример:
    A poll bot for groups runs in privacy mode (only receives commands, replies to its messages and mentions). There could be two ways to create a new poll: 

    Explain the user how to send a command with parameters (e.g. /newpoll question answer1 answer2). May be appealing for hardcore users but lacks modern day polish.
    Guide the user through a step-by-step process. ‘Please send me your question’, ‘Cool, now let’s add the first answer option‘, ’Great. Keep adding answer options, then send /done when you‘re ready’.

The last option is definitely more attractive. And if you use ForceReply in your bot‘s questions, it will receive the user’s answers even if it only receives replies, commands and mentions — without any extra work for the user.
ResponseParameters

Содержит информацию о том, почему запрос не был успешен.
Field 	Type 	Description
migrate_to_chat_id 	Integer 	Optional. The group has been migrated to a supergroup with the specified identifier. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
retry_after 	Integer 	Optional. In case of exceeding flood control, the number of seconds left to wait before the request can be repeated
InputFile

This object represents the contents of a file to be uploaded. Must be posted using multipart/form-data in the usual way that files are uploaded via the browser.
Resending files without reuploading

There are two ways of sending a file (photo, sticker, audio etc.). If it‘s a new file, you can upload it using multipart/form-data. If the file is already on our servers, you don’t need to reupload it: each file object has a file_id field, you can simply pass this file_id as a parameter instead.

    It is not possible to change the file type when resending by file_id. I.e. a video can't be sent as a photo, a photo can't be sent as a document, etc.
    It is not possible to resend thumbnails.
    Resending a photo by file_id will send all of its sizes.

Inline mode objects

Objects and methods used in the inline mode are described in the Inline mode section.
Доступные методы

    All methods in the Bot API are case-insensitive. We support GET and POST HTTP methods. Use either URL query string or application/json or application/x-www-form-urlencoded or multipart/form-data for passing parameters in Bot API requests.
    On successful call, a JSON-object containing the result will be returned. 

getMe

A simple method for testing your bot's auth token. Requires no parameters. Returns basic information about the bot in form of a User object.
sendMessage

Use this method to send text messages. On success, the sent Message is returned.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target chat or username of the target channel (in the format @channelusername)
text 	String 	Yes 	Text of the message to be sent
parse_mode 	String 	Необязательный 	Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot's message.
disable_web_page_preview 	Boolean 	Необязательный 	Disables link previews for links in this message
disable_notification 	Boolean 	Необязательный 	Sends the message silently. iOS users will not receive a notification, Android users will receive a notification with no sound.
reply_to_message_id 	Integer 	Необязательный 	If the message is a reply, ID of the original message
reply_markup 	InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply 	Необязательный 	Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to hide reply keyboard or to force a reply from the user.
Formatting options

The Bot API supports basic formatting for messages. You can use bold and italic text, as well as inline links and pre-formatted code in your bots' messages. Telegram clients will render them accordingly. You can use either markdown-style or HTML-style formatting.

Note that Telegram clients will display an alert to the user before opening an inline link (‘Open this link?’ together with the full URL).
Markdown style

To use this mode, pass Markdown in the parse_mode field when using sendMessage. Use the following syntax in your message:

*bold text*
        _italic text_
        [text](URL)
        `inline fixed-width code`
        ```pre-formatted fixed-width code block```

HTML style

To use this mode, pass HTML in the parse_mode field when using sendMessage. The following tags are currently supported:

<b>bold</b>, <strong>bold</strong>
        <i>italic</i>, <em>italic</em>
        <a href="URL">inline URL</a>
        <code>inline fixed-width code</code>
        <pre>pre-formatted fixed-width code block</pre>

Please note:

    Only the tags mentioned above are currently supported.
    Tags must not be nested.
    All <, > and & symbols that are not a part of a tag or an HTML entity must be replaced with the corresponding HTML entities (< with &lt;, > with &gt; and & with &amp;).
    All numerical HTML entities are supported.
    The API currently supports only the following named HTML entities: &lt;, &gt;, &amp; and &quot;.

forwardMessage

Use this method to forward messages of any kind. On success, the sent Message is returned.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target chat or username of the target channel (in the format @channelusername)
from_chat_id 	Integer or String 	Yes 	Unique identifier for the chat where the original message was sent (or channel username in the format @channelusername)
disable_notification 	Boolean 	Необязательный 	Sends the message silently. iOS users will not receive a notification, Android users will receive a notification with no sound.
message_id 	Integer 	Yes 	Unique message identifier
sendPhoto

Use this method to send photos. On success, the sent Message is returned.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target chat or username of the target channel (in the format @channelusername)
photo 	InputFile or String 	Yes 	Photo to send. You can either pass a file_id as String to resend a photo that is already on the Telegram servers, or upload a new photo using multipart/form-data.
caption 	String 	Необязательный 	Photo caption (may also be used when resending photos by file_id), 0-200 characters
disable_notification 	Boolean 	Необязательный 	Sends the message silently. iOS users will not receive a notification, Android users will receive a notification with no sound.
reply_to_message_id 	Integer 	Необязательный 	If the message is a reply, ID of the original message
reply_markup 	InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply 	Необязательный 	Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to hide reply keyboard or to force a reply from the user.
sendAudio

Use this method to send audio files, if you want Telegram clients to display them in the music player. Your audio must be in the .mp3 format. On success, the sent Message is returned. Bots can currently send audio files of up to 50 MB in size, this limit may be changed in the future.

For sending voice messages, use the sendVoice method instead.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target chat or username of the target channel (in the format @channelusername)
audio 	InputFile or String 	Yes 	Audio file to send. You can either pass a file_id as String to resend an audio that is already on the Telegram servers, or upload a new audio file using multipart/form-data.
caption 	Integer 	Необязательный 	Название аудио, 0-200 символов
duration 	Integer 	Необязательный 	Duration of the audio in seconds
performer 	String 	Необязательный 	Performer
title 	String 	Необязательный 	Track name
disable_notification 	Boolean 	Необязательный 	Sends the message silently. iOS users will not receive a notification, Android users will receive a notification with no sound.
reply_to_message_id 	Integer 	Необязательный 	If the message is a reply, ID of the original message
reply_markup 	InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply 	Необязательный 	Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to hide reply keyboard or to force a reply from the user.
sendDocument

Use this method to send general files. On success, the sent Message is returned. Bots can currently send files of any type of up to 50 MB in size, this limit may be changed in the future.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target chat or username of the target channel (in the format @channelusername)
document 	InputFile or String 	Yes 	File to send. You can either pass a file_id as String to resend a file that is already on the Telegram servers, or upload a new file using multipart/form-data.
caption 	String 	Необязательный 	Document caption (may also be used when resending documents by file_id), 0-200 characters
disable_notification 	Boolean 	Необязательный 	Sends the message silently. iOS users will not receive a notification, Android users will receive a notification with no sound.
reply_to_message_id 	Integer 	Необязательный 	If the message is a reply, ID of the original message
reply_markup 	InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply 	Необязательный 	Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to hide reply keyboard or to force a reply from the user.
sendSticker

Use this method to send .webp stickers. On success, the sent Message is returned.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target chat or username of the target channel (in the format @channelusername)
sticker 	InputFile or String 	Yes 	Sticker to send. You can either pass a file_id as String to resend a sticker that is already on the Telegram servers, or upload a new sticker using multipart/form-data.
disable_notification 	Boolean 	Необязательный 	Sends the message silently. iOS users will not receive a notification, Android users will receive a notification with no sound.
reply_to_message_id 	Integer 	Необязательный 	If the message is a reply, ID of the original message
reply_markup 	InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply 	Необязательный 	Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to hide reply keyboard or to force a reply from the user.
sendVideo

Use this method to send video files, Telegram clients support mp4 videos (other formats may be sent as Document). On success, the sent Message is returned. Bots can currently send video files of up to 50 MB in size, this limit may be changed in the future.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target chat or username of the target channel (in the format @channelusername)
video 	InputFile or String 	Yes 	Video to send. You can either pass a file_id as String to resend a video that is already on the Telegram servers, or upload a new video file using multipart/form-data.
duration 	Integer 	Необязательный 	Duration of sent video in seconds
width 	Integer 	Необязательный 	Video width
height 	Integer 	Необязательный 	Video height
caption 	String 	Необязательный 	Video caption (may also be used when resending videos by file_id), 0-200 characters
disable_notification 	Boolean 	Необязательный 	Sends the message silently. iOS users will not receive a notification, Android users will receive a notification with no sound.
reply_to_message_id 	Integer 	Необязательный 	If the message is a reply, ID of the original message
reply_markup 	InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply 	Необязательный 	Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to hide reply keyboard or to force a reply from the user.
sendVoice

Use this method to send audio files, if you want Telegram clients to display the file as a playable voice message. For this to work, your audio must be in an .ogg file encoded with OPUS (other formats may be sent as Audio or Document). On success, the sent Message is returned. Bots can currently send voice messages of up to 50 MB in size, this limit may be changed in the future.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target chat or username of the target channel (in the format @channelusername)
voice 	InputFile or String 	Yes 	Audio file to send. You can either pass a file_id as String to resend an audio that is already on the Telegram servers, or upload a new audio file using multipart/form-data.
caption 	Integer 	Необязательный 	Название аудиосообщения, 0-200 символов
duration 	Integer 	Необязательный 	Duration of sent audio in seconds
disable_notification 	Boolean 	Необязательный 	Sends the message silently. iOS users will not receive a notification, Android users will receive a notification with no sound.
reply_to_message_id 	Integer 	Необязательный 	If the message is a reply, ID of the original message
reply_markup 	InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply 	Необязательный 	Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to hide reply keyboard or to force a reply from the user.
sendLocation

Use this method to send point on the map. On success, the sent Message is returned.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target chat or username of the target channel (in the format @channelusername)
latitude 	Float number 	Yes 	Latitude of location
longitude 	Float number 	Yes 	Longitude of location
disable_notification 	Boolean 	Необязательный 	Sends the message silently. iOS users will not receive a notification, Android users will receive a notification with no sound.
reply_to_message_id 	Integer 	Необязательный 	If the message is a reply, ID of the original message
reply_markup 	InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply 	Необязательный 	Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to hide reply keyboard or to force a reply from the user.
sendVenue

Use this method to send information about a venue. On success, the sent Message is returned.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target chat or username of the target channel (in the format @channelusername)
latitude 	Float number 	Yes 	Latitude of the venue
longitude 	Float number 	Yes 	Longitude of the venue
title 	String 	Yes 	Name of the venue
address 	String 	Yes 	Address of the venue
foursquare_id 	String 	Необязательный 	Foursquare identifier of the venue
disable_notification 	Boolean 	Необязательный 	Sends the message silently. iOS users will not receive a notification, Android users will receive a notification with no sound.
reply_to_message_id 	Integer 	Необязательный 	If the message is a reply, ID of the original message
reply_markup 	InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply 	Необязательный 	Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to hide reply keyboard or to force a reply from the user.
sendContact

Use this method to send phone contacts. On success, the sent Message is returned.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target chat or username of the target channel (in the format @channelusername)
phone_number 	String 	Yes 	Contact's phone number
first_name 	String 	Yes 	Contact's first name
last_name 	String 	Необязательный 	Contact's last name
disable_notification 	Boolean 	Необязательный 	Sends the message silently. iOS users will not receive a notification, Android users will receive a notification with no sound.
reply_to_message_id 	Integer 	Необязательный 	If the message is a reply, ID of the original message
reply_markup 	InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply 	Необязательный 	Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to hide keyboard or to force a reply from the user.
sendChatAction

Use this method when you need to tell the user that something is happening on the bot's side. The status is set for 5 seconds or less (when a message arrives from your bot, Telegram clients clear its typing status).

    Пример:
    The ImageBot needs some time to process a request and upload the image. Instead of sending a text message along the lines of “Retrieving image, please wait…”, the bot may use sendChatAction with action = upload_photo. The user will see a “sending photo” status for the bot. 

We only recommend using this method when a response from the bot will take a noticeable amount of time to arrive.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target chat or username of the target channel (in the format @channelusername)
action 	String 	Yes 	Type of action to broadcast. Choose one, depending on what the user is about to receive: typing for text messages, upload_photo for photos, record_video or upload_video for videos, record_audio or upload_audio for audio files, upload_document for general files, find_location for location data.
getUserProfilePhotos

Use this method to get a list of profile pictures for a user. Returns a UserProfilePhotos object.
Параметры 	Тип 	Обязательный 	Описание
user_id 	Integer 	Yes 	Unique identifier of the target user
offset 	Integer 	Необязательный 	Sequential number of the first photo to be returned. By default, all photos are returned.
limit 	Integer 	Необязательный 	Limits the number of photos to be retrieved. Values between 1—100 are accepted. Defaults to 100.
getFile

Use this method to get basic info about a file and prepare it for downloading. For the moment, bots can download files of up to 20MB in size. On success, a File object is returned. The file can then be downloaded via the link https://api.telegram.org/file/bot<token>/<file_path>, where <file_path> is taken from the response. It is guaranteed that the link will be valid for at least 1 hour. When the link expires, a new one can be requested by calling getFile again.
Параметры 	Тип 	Обязательный 	Описание
file_id 	String 	Yes 	File identifier to get info about
kickChatMember

Use this method to kick a user from a group or a supergroup. In the case of supergroups, the user will not be able to return to the group on their own using invite links, etc., unless unbanned first. The bot must be an administrator in the group for this to work. Returns True on success.

    Внимание:
    This will method only work if the ‘All Members Are Admins’ setting is off in the target group. Otherwise members may only be removed by the group's creator or by the member that added them. 

Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target group or username of the target supergroup (in the format @supergroupusername)
user_id 	Integer 	Yes 	Unique identifier of the target user
unbanChatMember

Use this method to unban a previously kicked user in a supergroup. The user will not return to the group automatically, but will be able to join via link, etc. The bot must be an administrator in the group for this to work. Returns True on success.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	Yes 	Unique identifier for the target group or username of the target supergroup (in the format @supergroupusername)
user_id 	Integer 	Yes 	Unique identifier of the target user
answerCallbackQuery

Use this method to send answers to callback queries sent from inline keyboards. The answer will be displayed to the user as a notification at the top of the chat screen or as an alert. On success, True is returned.
Параметры 	Тип 	Обязательный 	Описание
callback_query_id 	String 	Yes 	Unique identifier for the query to be answered
text 	String 	Необязательный 	Text of the notification. If not specified, nothing will be shown to the user
show_alert 	Boolean 	Необязательный 	If true, an alert will be shown by the client instead of a notification at the top of the chat screen. Defaults to false.
url 	String 	Необязательный 	URL, который будет открыт у пользователя. Если вы создали игру, приняв условия @Botfather, укажите адрес, на котором расположена ваша игра. Учтите, что это будет работать только если запрос исходит от кнопки callback_game.
В остальных случаях вы можете использовать параметр для создания ссылок вида telegram.me/your_bot?start=XXXX
Inline mode methods

Methods and objects used in the inline mode are described in the Inline mode section.
Updating messages

The following methods allow you to change an existing message in the message history instead of sending a new one with a result of an action. This is most useful for messages with inline keyboards using callback queries, but can also help reduce clutter in conversations with regular chat bots.

Please note, that it is currently only possible to edit messages without reply_markup or with inline keyboards.
editMessageText

Use this method to edit text messages sent by the bot or via the bot (for inline bots). On success, the edited Message is returned.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	No 	Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
message_id 	Integer 	No 	Required if inline_message_id is not specified. Unique identifier of the sent message
inline_message_id 	String 	No 	Required if chat_id and message_id are not specified. Identifier of the inline message
text 	String 	Yes 	New text of the message
parse_mode 	String 	Необязательный 	Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot's message.
disable_web_page_preview 	Boolean 	Необязательный 	Disables link previews for links in this message
reply_markup 	InlineKeyboardMarkup 	Необязательный 	A JSON-serialized object for an inline keyboard.
editMessageCaption

Use this method to edit captions of messages sent by the bot or via the bot (for inline bots). On success, the edited Message is returned.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	No 	Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
message_id 	Integer 	No 	Required if inline_message_id is not specified. Unique identifier of the sent message
inline_message_id 	String 	No 	Required if chat_id and message_id are not specified. Identifier of the inline message
caption 	String 	Необязательный 	New caption of the message
reply_markup 	InlineKeyboardMarkup 	Необязательный 	A JSON-serialized object for an inline keyboard.
editMessageReplyMarkup

Use this method to edit only the reply markup of messages sent by the bot or via the bot (for inline bots). On success, the edited Message is returned.
Параметры 	Тип 	Обязательный 	Описание
chat_id 	Integer or String 	No 	Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
message_id 	Integer 	No 	Required if inline_message_id is not specified. Unique identifier of the sent message
inline_message_id 	String 	No 	Required if chat_id and message_id are not specified. Identifier of the inline message
reply_markup 	InlineKeyboardMarkup 	Необязательный 	A JSON-serialized object for an inline keyboard.
Inline-режим

The following methods and objects allow your bot to work in inline mode.
Please see our Introduction to Inline bots for more details.

To enable this option, send the /setinline command to @BotFather and provide the placeholder text that the user will see in the input field after typing your bot’s name.
InlineQuery

This object represents an incoming inline query. When the user sends an empty query, your bot could return some default or trending results.
Поле 	Тип 	Описание
id 	String 	Unique identifier for this query
from 	User 	Sender
location 	Location 	Опционально. Sender location, only for bots that request user location
query 	String 	Text of the query
offset 	String 	Offset of the results to be returned, can be controlled by the bot
answerInlineQuery

Use this method to send answers to an inline query. On success, True is returned.
No more than 50 results per query are allowed.
Параметры 	Тип 	Обязательный 	Описание
inline_query_id 	String 	Yes 	Unique identifier for the answered query
results 	Array of InlineQueryResult 	Yes 	A JSON-serialized array of results for the inline query
cache_time 	Integer 	Необязательный 	The maximum amount of time in seconds that the result of the inline query may be cached on the server. Defaults to 300.
is_personal 	Boolean 	Необязательный 	Pass True, if results may be cached on the server side only for the user that sent the query. By default, results may be returned to any user who sends the same query
next_offset 	String 	Необязательный 	Pass the offset that a client should send in the next query with the same text to receive more results. Pass an empty string if there are no more results or if you don‘t support pagination. Offset length can’t exceed 64 bytes.
switch_pm_text 	String 	Необязательный 	If passed, clients will display a button with specified text that switches the user to a private chat with the bot and sends the bot a start message with the parameter switch_pm_parameter
switch_pm_parameter 	String 	Необязательный 	Parameter for the start message sent to the bot when user presses the switch button

Example: An inline bot that sends YouTube videos can ask the user to connect the bot to their YouTube account to adapt search results accordingly. To do this, it displays a ‘Connect your YouTube account’ button above the results, or even before showing any. The user presses the button, switches to a private chat with the bot and, in doing so, passes a start parameter that instructs the bot to return an oauth link. Once done, the bot can offer a switch_inline button so that the user can easily return to the chat where they wanted to use the bot's inline capabilities.
InlineQueryResult

This object represents one result of an inline query. Telegram clients currently support results of the following 19 types:

    InlineQueryResultCachedAudio
    InlineQueryResultCachedDocument
    InlineQueryResultCachedGif
    InlineQueryResultCachedMpeg4Gif
    InlineQueryResultCachedPhoto
    InlineQueryResultCachedSticker
    InlineQueryResultCachedVideo
    InlineQueryResultCachedVoice
    InlineQueryResultArticle
    InlineQueryResultAudio
    InlineQueryResultContact
    InlineQueryResultDocument
    InlineQueryResultGif
    InlineQueryResultLocation
    InlineQueryResultMpeg4Gif
    InlineQueryResultPhoto
    InlineQueryResultVenue
    InlineQueryResultVideo
    InlineQueryResultVoice

InlineQueryResultArticle

Represents a link to an article or web page.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be article
id 	String 	Unique identifier for this result, 1-64 Bytes
title 	String 	Title of the result
input_message_content 	InputMessageContent 	Content of the message to be sent
reply_markup 	InlineKeyboardMarkup 	Опционально. Inline keyboard attached to the message
url 	String 	Опционально. URL of the result
hide_url 	Boolean 	Опционально. Pass True, if you don't want the URL to be shown in the message
description 	String 	Опционально. Short description of the result
thumb_url 	String 	Опционально. Url of the thumbnail for the result
thumb_width 	Integer 	Опционально. Thumbnail width
thumb_height 	Integer 	Опционально. Thumbnail height
InlineQueryResultPhoto

Represents a link to a photo. By default, this photo will be sent by the user with optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the photo.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be photo
id 	String 	Unique identifier for this result, 1-64 bytes
photo_url 	String 	A valid URL of the photo. Photo must be in jpeg format. Photo size must not exceed 5MB
thumb_url 	String 	URL of the thumbnail for the photo
photo_width 	Integer 	Опционально. Width of the photo
photo_height 	Integer 	Опционально. Height of the photo
title 	String 	Опционально. Title for the result
description 	String 	Опционально. Short description of the result
caption 	String 	Опционально. Caption of the photo to be sent, 0-200 characters
reply_markup 	InlineKeyboardMarkup 	Опционально. Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the photo
InlineQueryResultGif

Represents a link to an animated GIF file. By default, this animated GIF file will be sent by the user with optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the animation.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be gif
id 	String 	Unique identifier for this result, 1-64 bytes
gif_url 	String 	A valid URL for the GIF file. Размер файла must not exceed 1MB
gif_width 	Integer 	Опционально. Width of the GIF
gif_height 	Integer 	Опционально. Height of the GIF
thumb_url 	String 	URL of the static thumbnail for the result (jpeg or gif)
title 	String 	Опционально. Title for the result
caption 	String 	Опционально. Caption of the GIF file to be sent, 0-200 characters
reply_markup 	InlineKeyboardMarkup 	Опционально. Inline keyboard attached to the message
input_message_content 	inputMessageContent 	Опционально. Content of the message to be sent instead of the GIF animation
InlineQueryResultMpeg4Gif

Represents a link to a video animation (H.264/MPEG-4 AVC video without sound). By default, this animated MPEG-4 file will be sent by the user with optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the animation.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be mpeg4_gif
id 	String 	Unique identifier for this result, 1-64 bytes
mpeg4_url 	String 	A valid URL for the MP4 file. Размер файла must not exceed 1MB
mpeg4_width 	Integer 	Опционально. Video width
mpeg4_height 	Integer 	Опционально. Video height
thumb_url 	String 	URL of the static thumbnail (jpeg or gif) for the result
title 	String 	Опционально. Title for the result
caption 	String 	Опционально. Caption of the MPEG-4 file to be sent, 0-200 characters
reply_markup 	InlineKeyboardMarkup 	Опционально. Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the video animation
InlineQueryResultVideo

Represents a link to a page containing an embedded video player or a video file. By default, this video file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the video.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be video
id 	String 	Unique identifier for this result, 1-64 bytes
video_url 	String 	A valid URL for the embedded video player or video file
mime_type 	String 	Mime type of the content of video url, “text/html” or “video/mp4”
thumb_url 	String 	URL of the thumbnail (jpeg only) for the video
title 	String 	Title for the result
caption 	String 	Опционально. Caption of the video to be sent, 0-200 characters
video_width 	Integer 	Опционально. Video width
video_height 	Integer 	Опционально. Video height
video_duration 	Integer 	Опционально. Video duration in seconds
description 	String 	Опционально. Short description of the result
reply_markup 	InlineKeyboardMarkup 	Опционально. Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the video
InlineQueryResultAudio

Represents a link to an mp3 audio file. By default, this audio file will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the audio.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be audio
id 	String 	Unique identifier for this result, 1-64 bytes
audio_url 	String 	A valid URL for the audio file
title 	String 	Title
caption 	Integer 	Необязательный 	Название аудио, 0-200 символов
performer 	String 	Опционально. Performer
audio_duration 	Integer 	Опционально. Audio duration in seconds
reply_markup 	InlineKeyboardMarkup 	Опционально. Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the audio

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
InlineQueryResultVoice

Represents a link to a voice recording in an .ogg container encoded with OPUS. By default, this voice recording will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the the voice message.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be voice
id 	String 	Unique identifier for this result, 1-64 bytes
voice_url 	String 	A valid URL for the voice recording
title 	String 	Recording title
caption 	Integer 	Необязательный 	Название голосового сообщения, 0-200 символов
voice_duration 	Integer 	Опционально. Recording duration in seconds
reply_markup 	InlineKeyboardMarkup 	Опционально. Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the voice recording

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
InlineQueryResultDocument

Represents a link to a file. By default, this file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the file. Currently, only .PDF and .ZIP files can be sent using this method.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be document
id 	String 	Unique identifier for this result, 1-64 bytes
title 	String 	Title for the result
caption 	String 	Опционально. Caption of the document to be sent, 0-200 characters
document_url 	String 	A valid URL for the file
mime_type 	String 	Mime type of the content of the file, either “application/pdf” or “application/zip”
description 	String 	Опционально. Short description of the result
reply_markup 	InlineKeyboardMarkup 	Опционально. Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the file
thumb_url 	String 	Опционально. URL of the thumbnail (jpeg only) for the file
thumb_width 	Integer 	Опционально. Thumbnail width
thumb_height 	Integer 	Опционально. Thumbnail height

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
InlineQueryResultLocation

Represents a location on a map. By default, the location will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the location.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be location
id 	String 	Unique identifier for this result, 1-64 Bytes
latitude 	Float number 	Location latitude in degrees
longitude 	Float number 	Location longitude in degrees
title 	String 	Location title
reply_markup 	InlineKeyboardMarkup 	Опционально. Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the location
thumb_url 	String 	Опционально. Url of the thumbnail for the result
thumb_width 	Integer 	Опционально. Thumbnail width
thumb_height 	Integer 	Опционально. Thumbnail height

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
InlineQueryResultVenue

Represents a venue. By default, the venue will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the venue.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be venue
id 	String 	Unique identifier for this result, 1-64 Bytes
latitude 	Float 	Latitude of the venue location in degrees
longitude 	Float 	Longitude of the venue location in degrees
title 	String 	Title of the venue
address 	String 	Address of the venue
foursquare_id 	String 	Опционально. Foursquare identifier of the venue if known
reply_markup 	InlineKeyboardMarkup 	Опционально. Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the venue
thumb_url 	String 	Опционально. Url of the thumbnail for the result
thumb_width 	Integer 	Опционально. Thumbnail width
thumb_height 	Integer 	Опционально. Thumbnail height

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
InlineQueryResultContact

Represents a contact with a phone number. By default, this contact will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the contact.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be contact
id 	String 	Unique identifier for this result, 1-64 Bytes
phone_number 	String 	Contact's phone number
first_name 	String 	Contact's first name
last_name 	String 	Опционально. Contact's last name
reply_markup 	InlineKeyboardMarkup 	Опционально. Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the contact
thumb_url 	String 	Опционально. Url of the thumbnail for the result
thumb_width 	Integer 	Опционально. Thumbnail width
thumb_height 	Integer 	Опционально. Thumbnail height

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
InlineQueryResultCachedPhoto

Represents a link to a photo stored on the Telegram servers. By default, this photo will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the photo.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be photo
id 	String 	Unique identifier for this result, 1-64 bytes
photo_file_id 	String 	A valid file identifier of the photo
title 	String 	Опционально. Title for the result
description 	String 	Опционально. Short description of the result
caption 	String 	Опционально. Caption of the photo to be sent, 0-200 characters
reply_markup 	InlineKeyboardMarkup 	Опционально. Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the photo
InlineQueryResultCachedGif

Represents a link to an animated GIF file stored on the Telegram servers. By default, this animated GIF file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with specified content instead of the animation.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be gif
id 	String 	Unique identifier for this result, 1-64 bytes
gif_file_id 	String 	A valid file identifier for the GIF file
title 	String 	Опционально. Title for the result
caption 	String 	Опционально. Caption of the GIF file to be sent, 0-200 characters
reply_markup 	InlineKeyboardMarkup 	Опционально. An Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the GIF animation
InlineQueryResultCachedMpeg4Gif

Represents a link to a video animation (H.264/MPEG-4 AVC video without sound) stored on the Telegram servers. By default, this animated MPEG-4 file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the animation.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be mpeg4_gif
id 	String 	Unique identifier for this result, 1-64 bytes
mpeg4_file_id 	String 	A valid file identifier for the MP4 file
title 	String 	Опционально. Title for the result
caption 	String 	Опционально. Caption of the MPEG-4 file to be sent, 0-200 characters
reply_markup 	InlineKeyboardMarkup 	Опционально. An Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the video animation
InlineQueryResultCachedSticker

Represents a link to a sticker stored on the Telegram servers. By default, this sticker will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the sticker.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be sticker
id 	String 	Unique identifier for this result, 1-64 bytes
sticker_file_id 	String 	A valid file identifier of the sticker
reply_markup 	InlineKeyboardMarkup 	Опционально. An Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the sticker

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
InlineQueryResultCachedDocument

Represents a link to a file stored on the Telegram servers. By default, this file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the file. Currently, only pdf-files and zip archives can be sent using this method.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be document
id 	String 	Unique identifier for this result, 1-64 bytes
title 	String 	Title for the result
document_file_id 	String 	A valid file identifier for the file
description 	String 	Опционально. Short description of the result
caption 	String 	Опционально. Caption of the document to be sent, 0-200 characters
reply_markup 	InlineKeyboardMarkup 	Опционально. An Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the file

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
InlineQueryResultCachedVideo

Represents a link to a video file stored on the Telegram servers. By default, this video file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the video.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be video
id 	String 	Unique identifier for this result, 1-64 bytes
video_file_id 	String 	A valid file identifier for the video file
title 	String 	Title for the result
description 	String 	Опционально. Short description of the result
caption 	String 	Опционально. Caption of the video to be sent, 0-200 characters
reply_markup 	InlineKeyboardMarkup 	Опционально. An Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the video
InlineQueryResultCachedVoice

Represents a link to a voice message stored on the Telegram servers. By default, this voice message will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the voice message.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be voice
id 	String 	Unique identifier for this result, 1-64 bytes
voice_file_id 	String 	A valid file identifier for the voice message
title 	String 	Voice message title
caption 	Integer 	Необязательный 	Название аудиосообщения, 0-200 символов
reply_markup 	InlineKeyboardMarkup 	Опционально. An Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the voice message

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
InlineQueryResultCachedAudio

Represents a link to an mp3 audio file stored on the Telegram servers. By default, this audio file will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the audio.
Поле 	Тип 	Описание
type 	String 	Type of the result, must be audio
id 	String 	Unique identifier for this result, 1-64 bytes
caption 	Integer 	Необязательный 	Название аудио, 0-200 символов
audio_file_id 	String 	A valid file identifier for the audio file
reply_markup 	InlineKeyboardMarkup 	Опционально. An Inline keyboard attached to the message
input_message_content 	InputMessageContent 	Опционально. Content of the message to be sent instead of the audio

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
InputMessageContent

This object represents the content of a message to be sent as a result of an inline query. Telegram clients currently support the following 4 types:

    InputTextMessageContent
    InputLocationMessageContent
    InputVenueMessageContent
    InputContactMessageContent

InputTextMessageContent

Represents the content of a text message to be sent as the result of an inline query.
Поле 	Тип 	Описание
message_text 	String 	Text of the message to be sent, 1-4096 characters
parse_mode 	String 	Опционально. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot's message.
disable_web_page_preview 	Boolean 	Опционально. Disables link previews for links in the sent message
InputLocationMessageContent

Represents the content of a location message to be sent as the result of an inline query.
Поле 	Тип 	Описание
latitude 	Float 	Latitude of the location in degrees
longitude 	Float 	Longitude of the location in degrees

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
InputVenueMessageContent

Represents the content of a venue message to be sent as the result of an inline query.
Поле 	Тип 	Описание
latitude 	Float 	Latitude of the venue in degrees
longitude 	Float 	Longitude of the venue in degrees
title 	String 	Name of the venue
address 	String 	Address of the venue
foursquare_id 	String 	Опционально. Foursquare identifier of the venue, if known

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
InputContactMessageContent

Represents the content of a contact message to be sent as the result of an inline query.
Поле 	Тип 	Описание
phone_number 	String 	Contact's phone number
first_name 	String 	Contact's first name
last_name 	String 	Опционально. Contact's last name

Note: This will only work in Telegram versions released after 9 April, 2016. Older clients will ignore them.
ChosenInlineResult

Represents a result of an inline query that was chosen by the user and sent to their chat partner.
Поле 	Тип 	Описание
result_id 	String 	The unique identifier for the result that was chosen
from 	User 	The user that chose the result
location 	Location 	Опционально. Sender location, only for bots that require user location
inline_message_id 	String 	Опционально. Identifier of the sent inline message. Available only if there is an inline keyboard attached to the message. Will be also received in callback queries and can be used to edit the message.
query 	String 	The query that was used to obtain the result
Игры

Боты теперь умеют предоставлять пользователям возможность поиграть в HTML5-игры. Создать игру можно при помощи бота @BotFather и команды /newgame. Обратите внимание, что для создания игры вам нужно принять соглашение.

    Игры — новый тип контента, представленный объектами Game и InlineQueryResultGame.
    Как только вы создали игру с помощью бота BotFather, вы сможее отправлять игры в чаты или при помощи метода sendGame, или используя встроенный режим с методом InlineQueryResultGame.
    Если вы отправите сообщение с игрой без каких-либо кнопок, к нему автоматически добавится кнопка 'Играть в ИмяИгры'. Когда кто-то нажмёт на эту кнопку, вашему боту придёт CallbackQuery с параметром game_short_name. После этого вы должны предоставить корректный URL страницы с игрой, который автоматически откроется во встроенном браузере у пользователя.
    Вы можете сами добавить сколько угодно кнопок к сообщению с игрой. Пожалуйста, обратите внимание, что первая кнопка в первом ряду всегда должна открывать игру. Для этого существует поле callback_game в объекте InlineKeyboardButton. Остальные кнопки могут быть какими угодно: ссылки на сайт игры, вызов правил, и т. д.
    Чтобы описание игры выглядело более привлекательно, вы можете загрузить GIF-анимацию с геймплеем игры. Сделать это можно при помощи бота BotFather (пример такой игры: Lumberjack).
    В сообщении с игрой также будет отображаться таблица рекордов для текущего чата. Чтобы отображать рекорды в чате с игрой, вы можете использовать метод setGameScore. Добавьте параметр edit_message, чтобы автоматически обновлять сообщение с таблицей рекордов.
    Чтобы отобразить таблицу рекордов прямо в вашем приложении, используйте метод getGameHighScores.
    Вы можете добавить кнопки «Поделиться», которые позволят пользователям отправлять свои результаты в чаты или группы.

sendGame

Этот метод используется для отправки игры в виде обычного сообщения. В случае успеха возвращает объект с отправленным сообщением Message.
Параметры 	Тип 	Обязательный? 	Описание
chat_id 	Integer или String 	Да 	Уникальный идентификатор целевого чата или юзернейм целевого канала (в формате @channelusername)
game_short_name 	String 	Да 	Короткое название игры, служит уникальным идентификатором игры. Задаётся в Botfather.
disable_notification 	Boolean 	Optional 	Sends the message silently. iOS users will not receive a notification, Android users will receive a notification with no sound.
reply_to_message_id 	Integer 	Нет 	Если сообщение является ответом, ID оригинального сообщения
reply_markup 	InlineKeyboardMarkup или ReplyKeyboardMarkup или ReplyKeyboardHide или ForceReply 	Нет 	Дополнительные параметры интерфейса. Сериализованные в JSON встроенные клавиатуры, обычные клавиатуры, инструкция скрыть клавиатуру или принудительного ответа.
Game

Этот объект представляет собой игру.
Поле 	Тип 	Описание
title 	String 	Название игры
description 	String 	Описание игры
photo 	Массив объектов PhotoSize 	Изображение, которое будет показываться в качестве обложки игры.
text 	String 	Опционально. Краткое описание игры или таблицы рекордов в сообщении с игрой. Может быть автоматически отредактировано, чтобы показывать текущую таблицу рекордов для игры при вызове ботом метода setGameScore, или ручном редактировании методом editMessageText. 0-4096 символов.
text_entities 	Массив объектов MessageEntity 	Опционально. Сущности в сообщении, типа имён пользователей, ссылок, команд и т. д.
animation 	Animation 	Опционально. Анимация, которая будет показана в опиании игры в сообщении.
Animation

Чтобы сообщение с игрой выглядело более привлекательно, вы можете загрузить для игры анимацию с геймплее. Этот объект представляет собой файл анимации, который будет отображён в сообщении с игрой.
Поле 	Тип 	Описание
file_id 	String 	Уникальный идентификатор файла
thumb 	PhotoSize 	Опционально. Превью анимации, заданное отправителем
file_name 	String 	Опционально. Название файла анимации, заданное отправителем
mime_type 	String 	Опционально. MIME-тип файла анимации, заданное отправителем
file_size 	Integer 	Опционально. Размер файла/td>
CallbackGame

Заглушка, пока не содержит никакой информации.
setGameScore

Используйте этот метод, чтобы обновить игровой счёт определённого пользователя. Если сообщение было отправлено ботом, вернёт отредактированное сообщение Message, иначе True. Вернёт ошибку, если вы попытаетесь установить новый счёт меньше, чем текущий.
Параметры 	Тип 	Обязательный? 	Описание
user_id 	Integer 	Да 	Идентификатор пользователя
score 	Integer 	Да 	Новый счёт, больше нуля
chat_id 	Integer или String 	Нет 	Необходим, если не указан inline_message_id. Уникальный идентификатор чата или имя пользователя канала (в формате @channelusername).
message_id 	Integer 	Нет 	Необходим, если не указан inline_message_id. Уникальный идентификатор отправленного сообщения
inline_message_id 	String 	Нет 	Необходим, если не указан chat_id или inline_message_id. Идентификатор встроенного сообщения
edit_message 	Boolean 	Нет 	Передайте True, чтобы в сообщение была автоматически встроена таблица рекордов
getGameHighScores

Используйте этот метод, чтобы получить данные для таблицы рекордов. Этот метод возвращает счёт указанного пользователя и нескольких его соседей по таблице. В случает успеха вернёт массив объектов GameHighScore.

    На текущий момент этот метод возвращает счёт пользователя и двух его ближайших соседей сверху и снизу. Кроме того вернёт топ-3 результатов, если запрошенный пользователь не находится среди них.
    В ближайшем будущем количество отдаваемых данных будет изменено. 

Параметры 	Тип 	Обязательный? 	Описание
user_id 	Integer 	Да 	Идентификатор пользователя
chat_id 	Integer или String 	Нет 	Необходим, если не указан inline_message_id. Уникальный идентификатор чата или имя пользователя канала (в формате @channelusername).
message_id 	Integer 	Нет 	Необходим, если не указан inline_message_id. Уникальный идентификатор отправленного сообщения
inline_message_id 	String 	Нет 	Необходим, если не указан chat_id или inline_message_id. Идентификатор встроенного сообщения
GameHighScore

Этот объект представляет собой один из рядов таблицы рекордов игры.
Поле 	Тип 	Описание
position 	Integer 	Место в таблице результатов
user 	User 	Пользователь
score 	Integer 	Счёт
