# Развёртывание SunFlowCRM локально

Репозиторий подключён через **git** (origin: `AnatolyBystrov/SunFlowCRM_DB`). Ветка `main` отслеживает `origin/main`.

- Файл **.env** уже создан (с ключами `SUPERTOKENS_API_KEY`, `INTERNAL_WORKER_SECRET`). При необходимости восстановите из бэкапа: `cp /tmp/SunFlow_env_backup.txt .env`
- В **RUN_THIS.sh** путь заменён на текущую директорию.

## Запуск у себя в терминале

1. **Зависимости:** `npm install` (или `bun install`)
2. **Инфраструктура:** `docker compose up -d postgres redis supertokens`
3. **Миграции:** `npx prisma migrate dev` или `npx prisma db push`
4. **Приложение:** `npm run dev:supertokens` или `npm run dev`
5. **(Опционально)** Воркер уведомлений в отдельном терминале: `npm run worker:notifications`

Подробнее — в **README.md**.
