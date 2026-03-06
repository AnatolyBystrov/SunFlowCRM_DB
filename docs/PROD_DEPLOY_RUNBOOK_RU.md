# SunFlow Production Runbook (Docker + Stack Auth)

Актуальная инструкция запуска production-стека на локальной машине/сервере через Docker Compose.

Инструкция учитывает текущую конфигурацию проекта:
- `docker-compose.prod.yml`
- `Dockerfile.stack-auth`
- `docker/clickhouse/users.d/allow-experimental-json.xml`
- `prisma.config.ts` (монтируется в `migrate`)

---

## 1) Требования

- Docker Engine + Docker Compose
- Доступ к портам:
  - `3000` (приложение)
  - `8101` (Stack Dashboard)
  - `8102` (Stack API)
  - `8105` (Inbucket UI, опционально)
- Заполненный `.env.prod`

Проверка:

```bash
docker --version
docker compose version
```

---

## 2) Подготовка переменных окружения

1. Создать `.env.prod` (если еще не создан):

```bash
cp .env.prod.example .env.prod
```

2. Обязательно заполнить:
- Postgres/Redis/Stack/ClickHouse пароли и секреты
- URL:
  - `NEXT_PUBLIC_APP_URL`
  - `NEXT_PUBLIC_STACK_URL`
  - `NEXT_PUBLIC_STACK_API_URL`

3. Ключи Stack проекта (`NEXT_PUBLIC_STACK_PROJECT_ID`, `NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY`, `STACK_SECRET_SERVER_KEY`) можно оставить плейсхолдерами до первого запуска Stack (см. шаг 5).

---

## 3) Сборка образов

Соберите приложение и патченный Stack Auth образ:

```bash
docker build -t sunflow-app:latest .
docker compose -f docker-compose.prod.yml --env-file .env.prod build stack-server
```

Зачем отдельный `stack-server` build:
- официальный `stackauth/server` образ в текущей версии требует runtime-дополнений для миграций;
- это уже учтено в `Dockerfile.stack-auth`.

---

## 4) Фаза 1: поднять Stack инфраструктуру

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d stack-postgres clickhouse inbucket stack-server
```

Проверка:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod ps
```

Ожидаемо для `stack-server`:
- статус `Up (healthy)`
- `http://127.0.0.1:8101` -> 200
- `http://127.0.0.1:8102` -> 200

---

## 5) Фаза 2: создать Stack проект и получить ключи

1. Открыть Dashboard: `http://127.0.0.1:8101`
2. Зарегистрировать админа
3. Создать проект
4. Скопировать ключи в `.env.prod`:
- `NEXT_PUBLIC_STACK_PROJECT_ID=proj_...`
- `NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY=pck_...`
- `STACK_SECRET_SERVER_KEY=ssk_...`

После обновления `.env.prod` перезапустить `app`:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d app
```

---

## 6) Фаза 3: поднять полный стек

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

Проверка сервисов:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod ps
```

Должно быть:
- `postgres`, `redis`, `stack-postgres`, `clickhouse`, `stack-server`, `inbucket` -> `Up`
- `migrate` -> `Exited (0)` после успешных миграций
- `app`, `worker` -> `Up`

HTTP-проверка:

```bash
curl -I http://127.0.0.1:3000
curl -I http://127.0.0.1:8101
curl -I http://127.0.0.1:8102
```

---

## 7) Что проверить функционально

- Логин через Stack Auth
- Создание/чтение CRM сущностей
- Фоновый worker:
  - `notifications` очередь активна
  - scheduler reminder активен
- Migrations применены

Полезные логи:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod logs -f stack-server
docker compose -f docker-compose.prod.yml --env-file .env.prod logs -f app
docker compose -f docker-compose.prod.yml --env-file .env.prod logs -f worker
docker compose -f docker-compose.prod.yml --env-file .env.prod logs -f migrate
```

---

## 8) Частые проблемы и решения

### 8.1 `stack-server` рестартится с `ERR_MODULE_NOT_FOUND`
Проверьте, что используется сборка через `Dockerfile.stack-auth`:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod build --no-cache stack-server
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d stack-server
```

### 8.2 ClickHouse ошибки JSON/migrations
В проекте уже добавлен конфиг:
- `docker/clickhouse/users.d/allow-experimental-json.xml`

И он смонтирован в `clickhouse` сервис. Если меняли compose вручную, верните этот mount.

### 8.3 `migrate` падает с `datasource.url property is required`
Нужен `prisma.config.ts` внутри контейнера migrate (в текущем compose уже смонтирован):

```yaml
volumes:
  - ./prisma.config.ts:/app/prisma.config.ts:ro
```

### 8.4 `stack-server` долго `health: starting`
Проверить health endpoint и логи:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod ps stack-server
docker compose -f docker-compose.prod.yml --env-file .env.prod logs --tail=200 stack-server
```

---

## 9) Остановка и перезапуск

Остановить:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod down
```

Остановить с удалением томов (ОСТОРОЖНО, удаление данных):

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod down -v
```

Обычный перезапуск:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

