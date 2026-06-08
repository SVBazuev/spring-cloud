# spring-cloud – Инфраструктура микросервисов

Этот репозиторий содержит централизованную инфраструктуру для микросервисного окружения на базе Spring Cloud:

- #discovery-service – Eureka Server (Service Discovery)
- #config-server – Spring Cloud Config Server (External Configuration)
- #gateway-service – Spring Cloud Gateway (API Gateway)

Микросервисы `user-service` и `notification-service` подключаются к этой инфраструктуре через Eureka и Config Server.

---

## Быстрый старт

### 1. Клонирование инфраструктурного репозитория

```bash
git clone https://github.com/SVBazuev/spring-cloud.git
cd spring-cloud
```

### 2. Клонирование микросервисов (автоматически)

В папке `infrastructure` есть скрипт `clone-services.sh`. Запустите его:

```bash
cd infrastructure
./clone-services.sh   # для Linux/macOS
# или вручную:
git clone https://github.com/SVBazuev/user-service.git ../user-service
git clone https://github.com/SVBazuev/notification-service.git ../notification-service
```

После этого структура каталогов должна выглядеть так:

```
workspace/
├── spring-cloud/           # этот репозиторий
├── user-service/           # склонирован
└── notification-service/   # склонирован
```

### 3. Запуск всей системы

Из папки `spring-cloud` выполните:

```bash
docker-compose -f infrastructure/docker-compose.yml up -d --build
```

Первая сборка может занять несколько минут (Maven будет скачивать зависимости).  
Все сервисы будут запущены и зарегистрированы в Eureka.

---

## Проверка работы

### Service Discovery (Eureka)

Откройте в браузере: `http://localhost:8761`  
Вы должны увидеть приложения `GATEWAY-SERVICE`, `USER-SERVICE`, `NOTIFICATION-SERVICE`, `CONFIG-SERVER`.

### API Gateway

Все бизнес-запросы проходят через Gateway на порту `8080`:

- Получить список пользователей (Basic auth: `admin@demo.ya` / `admin123`)  
  `curl -u admin@demo.ya:admin123 http://localhost:8080/api/users`

- Создать пользователя  
  `curl -X POST http://localhost:8080/api/users -u admin@demo.ya:admin123 -H "Content-Type: application/json" -d '{"name":"John","email":"john@example.com","age":30,"password":"secret"}'`

### Swagger UI (документация API)

Swagger UI доступен напрямую через `user-service` (внутренний HTTP‑порт 8082):

- `http://localhost:8082/swagger-ui`   или   `http://localhost:8082/swagger-ui/index.html`

Если вы хотите просматривать документацию через Gateway, добавьте в `gateway-service/application.yml` маршрут для `/swagger-ui/**` и `lb://USER-SERVICE`, но в данной версии удобнее использовать прямой доступ.

### Circuit Breaker (проверка fallback)

Остановите `notification-service`:

```bash
docker stop notification-service
```

Затем создайте пользователя через Gateway – в логах `user-service` появится сообщение:

`Fallback: Could not send notification to ... due to: ... `

Запустите сервис обратно:

```bash
docker start notification-service
```

### Config Server

Проверить, что конфигурации отдаются:

`curl http://localhost:8888/user-service`  
`curl http://localhost:8888/notification-service`

---

## Структура репозитория

```
spring-cloud/
├── discovery-service/       # Eureka Server
├── config-server/           # Config Server (режим native)
├── gateway-service/         # Spring Cloud Gateway
├── infrastructure/
│   ├── clone-services.sh    # скрипт клонирования user-service и notification-service
│   ├── config-repo/         # файлы свойств для Config Server
│   │   ├── user-service.properties
│   │   ├── notification-service.properties
│   │   └── gateway-service.properties
│   └── docker-compose.yml   # полный compose‑файл для всех сервисов
└── README.md
```

---

## Остановка и очистка

Остановить все контейнеры:

```bash
docker-compose -f infrastructure/docker-compose.yml down
```

Полностью удалить тома (PostgreSQL, Kafka и т.д.):

```bash
docker-compose -f infrastructure/docker-compose.yml down -v
```

---

## Лицензия

MIT
