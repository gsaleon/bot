1. Второе задание (Задачки по языку)
https://www.schoolofhaskell.com/user/DanBurton/20-intermediate-exercises
  1. И выполнить следующие каты:
    1. Обязательные для прохождения:
      1. Бесконечные структуры
      2. Создание своих инстансов для 5 базовых монад
      3. Монадный стек Maybe + List + State
      4. Представление структур данных из функций
Практически любой тип данных можно представить даже в языке без специальных синтаксических конструкций, если
этот язык поддерживает функции высшего порядка и замыкания. Haskell как раз имеет специальные синтаксические
конструкции для создания алгебраических типов данных, однако на замену им могут прийти простые функции. Как с
их помощью сэмулировать пары, Maybe и даже списки как раз продемонстрирует эта ката.
Также для закрепления концепции алгебраических типов данных рекомендую подглаву 2.1 книги SICP, там этот
подход отлично описан. Саму книгу в целом тоже рекомендую в дальнейшем прочесть, хотя многие темы там уже по
продвинутым темам.
      1. Изоморфизм (на самом деле довольно простая и интересная ката)
    1. Необязательные для прохождения:
      1. Алгебраические изоморфизмы (после каты Изоморфизм)
      2. Синглтоны
Несложная ката, решив которую можно познакомиться с зависимыми типами. Несмотря на то, что в Хаскеле на данный
момент зависимых типов нет, последние можно сымитировать при помощи некоторых расширений ghci и типов-синглтонов
- типов, имеющих только одно значение.
      1. Корутины
      2. Lens
      3. Простой компилятор
Обязательно попробуйте найти и пройти еще от 3-х кат (1, 2 или 3 kyu) самостоятельно.
1. Третье задание (Бот)
Написать эхо-бота, который умеет просто отправлять сообщение от пользователя ему же в ответ.
Бот должен иметь возможность работать через несколько мессенджеров, пока как минимум сделать имплементацию для
Telegram и для VK:
Telegram: https://core.telegram.org/bots/api#poll
VK: https://vk.com/dev/bots_longpoll 
  1. Описание функциональных требований:
      1. Пользователь может отправить команду /help и увидеть текст, описывающий бота
      2. Пользователь может отправить команду /repeat и в ответ бот отправит какое сейчас выбрано значение
      повторов и вопрос, сколько раз повторять сообщение в дальнейшем. К вопросу будут прилагаться кнопки для
      выбора ответа (кнопки с цифрами от 1 до 5). После выбора пользователем, все ответы бота должны дублировать
      указанное кол-во раз. Кол-во повторов должно быть индивидуальным для каждого пользователя, т. е. если один
      пользователь выбрал 3 повторения, то второму мы по-прежнему показываем начальное кол-во сообщений.
      3. Все должно быть максимально кастомизируемо через конфиги
        1. Сообщение, отправляемое в ответ на /help.
        2. Вопрос по команде /repeat.
        3. Начальное кол-во повторов на каждый ответ.
  2. Описание технических требований:
      1. Специфичные правила для третьего задания (бота):
        * Для основного кода проекта (не тестов) использовать только библиотеки из стандартной поставки haskell-
        platform (bytestring, text, mtl etc, полный список) и три сторонние:
          1. Для отправки http-запросов
          2. Для парсинга json
          3. Для работы с конфигом.
        * Все остальное должно быть сделано по максимуму без библиотек. Для тестов можете использовать любой
        удобный вам инструмент (HSpec, HUnit, etc).
        * Обновления от Телеграма и ВК получать не посредством веб-хуков, а посредством поллинга:
Отправлять запрос за апдейтами телеграму, тот сам будет ставить ответ на паузу, если обновок нет, и отвечать сразу,
как только что-то появилось. Ну или отвечать пустым массивом по таймауту. Это требование вкупе с тем, что в
следующем задании надо будет свой сервер на Warp реализовать, поможет лучше понять, что такое модель поллинга и
модель пуша (через веб-хуки), в чем преимущества и недостатки каждой из моделей.
      1. Боты не обязательно запускать параллельно, а можно определять какой бот запустить на основе конфига или
      аргументов запуска программы.
  1. Следующие технические требования также распространяются и на следующее задание "Веб-сервер"
      1. Проект должен быть в отдельном репозитории на github, во время выполнения задания коммиты делать как можно
      чаще, как минимум раз в день, когда написана хоть строчка кода.
      2. Использовать stack, все используемые библиотеки должны быть зафиксированы в package.yaml, сам проект
      должен быть инициирован командой stack new, которая создает базовую структуру Haskell-проекта.
      3. Для разворачивания должно быть достаточно клонирования репозитория и запуска stack build. Обязательно
      проверить это правило клонированием репозитория в отдельную папку у себя и запуска stack build — результатом
      должны быть собранные и рабочие бинарники.
      4. У каждого проекта должно быть README с описанием того, как разворачивать проект локально и как его
      запускать, а так же с описанием базовой структуры, чтобы новичок мог легко разобраться (представьте, что
      после вас проект будет поддерживать совсем нулевой джуниор). Все должно быть на английском.
      5. Проект должен иметь файл .gitignore, куда внесены все автогенерируемые файлы проекта, локальные конфиги
      и тд.
Обязательно в .gitignore добавить следующие папки (даже если вы не пользуетесь редактором VSCode, им пользуемся
мы и это правило для нашего удобства при проверке):
.vscode 
.history
      1. Проект должен быть покрыт unit-тестами, которые бы покрывали главные use-case каждого модуля в приложении.
      2. Конфиги должны быть вынесены в отдельный файл с возможностью переписать локально какие-нибудь значения,
      но не изменять файлы из git-репозитория, чтобы случайно не запушить пароль или токен.
      3. Проект должен поддерживать логи разных уровней, все ключевые моменты должны грамотно логироваться, логи
      должны легко конфигурироваться хотя бы так, чтобы можно было включать/выключать логи до определенного уровня
      (например, показывать все от DEBUG и выше, или показывать все от WARN и выше).
      4. Для понятной архитектуры рекомендуем использовать Handle Pattern, так как мы применяем его в большинстве
      своих проектов.
      5. Чтобы добиться понятной архитектуры проекта, и получить тестируемый код, также можно применять различные
      техники (паттерны) описанные сообществом:
The Service Pattern
The ReaderT Design Pattern (Discussion)
Three Layer Haskell Cake
  1. Источники: 
      * Для начала можно посмотреть простую статью про то, как начать собирать первое приложение по отправке HTTP-
      запроса и получению одного нужного поля из JSON
      * Designing Testable Components
      * Полезные статьи для данного задания: https://tproger.ru/translations/telegram-bot-create-and-deploy/amp/ -
      по поводу бота
https://artyom.me/aeson 
https://ruhaskell.org/posts/packages/2015/02/03/aeson-hello-world.html
https://ruhaskell.org/posts/packages/2015/03/05/aeson-next.html