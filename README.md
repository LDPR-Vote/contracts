# ЛДПР: Инициатива народа

Цифровое приложение для вовлечения граждан в политические и социальные процессы при поддержке ЛДПР. Использует технологию DAG и Soulbound Tokens (SBT) для верификации пользователей и обеспечения прозрачности голосований.

---

## 🚀 Возможности

🔹 **Внутрирегиональные опросы**  
Платформа позволяет организовывать голосования по социально значимым вопросам в регионах, учитывая мнение граждан.

🔹 **Праймериз внутри партии**  
Поддержка прозрачного голосования для отбора кандидатов от партии ЛДПР.

🔹 **Голосование за проекты благоустройства**  
Каждый гражданин может предлагать и поддерживать проекты по улучшению городской среды.

---

## 🔐 Безопасность и прозрачность

- Использование **DAG** для хранения всех данных о голосованиях.
- Механизм **Soulbound Tokens (SBT)** гарантирует, что голосуют только верифицированные граждане.
- Голос передаётся только один раз и **не может быть передан другому** (невозможность передачи токена обеспечивает честность участия).

---

## 🛠️ Технологии

- Solidity (контракты: `IdentitySBT.sol`, `LDPRVoting.sol`)
- Hardhat (разработка и тестирование)
- Ethers.js
- Node.js

---

## 📂 Структура проекта

```
.
├── contracts/
│   ├── IdentitySBT.sol        # Контракт Soulbound-токена для верификации
│   └── LDPRVoting.sol         # Контракт для организации голосований
│
├── test/
│   └── LDPRVoting.test.js     # Юнит-тесты голосования с участием SBT
│
├── README.md                  # Описание проекта
└── hardhat.config.js          # Конфигурация Hardhat

---

## 📦 Установка и запуск

```bash
npm install
npx hardhat test
```

---

## ✅ Примеры

Пример создания голосования:

```js
await voting.connect(owner).createVote(
  "Поддерживаете ли вы проект нового парка?",
  ["Да", "Нет"],
  3600  // длительность голосования в секундах
);
```

Пример голосования:

```js
await voting.connect(alice).vote(1, 0);  // Голос "Да"
```

---

## 📜 Лицензия

Проект распространяется под лицензией MIT.

---