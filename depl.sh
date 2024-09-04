#!/bin/ш

wget -O loader.sh https://raw.githubusercontent.com/DiscoverMyself/Ramanode-Guides/main/loader.sh && chmod +x loader.sh && ./loader.sh
сон 4

sudo apt-get update && sudo apt-get upgrade -y
прозрачный

echo "Установка зависимостей..."
npm install --save-dev каска
npm установить dotenv
npm установить @swisstronik/utils
npm install @openzeppelin/contracts
echo "Установка завершена."

echo "Создание проекта Hardhat..."
каска npx

rm -f контракты/Lock.sol
echo "Lock.sol удален."

echo "Проект Hardhat создан."

echo "Установка Hardhat toolbox..."
npm install --save-dev @nomicfoundation/hardhat-toolbox
echo "Установлен ящик для инструментов Hardhat."

echo "Создание файла .env..."
read -p "Введите свой закрытый ключ: " PRIVATE_KEY
echo "PRIVATE_KEY=$PRIVATE_KEY" > .env
echo "Файл .env создан."

echo "Настройка Hardhat..."
кот <<EOL > hardhat.config.js
требуется("@nomicfoundation/hardhat-toolbox");
требуется("dotenv").config();

модуль.экспорты = {
  прочность: "0.8.20",
  сети: {
    swisstronik: {
      URL-адрес: "https://json-rpc.testnet.swisstronik.com/",
      учетные записи: [\`0x\${process.env.PRIVATE_KEY}\`],
    },
  },
};
ЭОЛ
echo "Конфигурация каски завершена."

read -p "Введите имя NFT: " NFT_NAME
read -p "Введите символ NFT: " NFT_SYMBOL

echo "Создание контракта PrivateNFT.sol..."
mkdir -p контракты
cat <<EOL > контракты/PrivateNFT.sol
// SPDX-Идентификатор лицензии: MIT
// Совместимо с контрактами OpenZeppelin ^5.0.0
прагма солидность ^0.8.20;

импортировать "@openzeppelin/contracts/token/ERC721/ERC721.sol";
импорт "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
импорт "@openzeppelin/contracts/access/Ownable.sol";

контракт PrivateNFT — это ERC721, ERC721Burnable, Ownable {
    конструктор(адрес initialOwner)
        ERC721("$NFT_NAME","$NFT_SYMBOL")
        Владеющий (первоначальный владелец)
    {}

    функция safeMint(адрес, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    функция balanceOf(владелец адреса) переопределение публичного представления возвращает (uint256) {
        require(msg.sender == owner, "PrivateNFT: msg.sender != owner");
        вернуть super.balanceOf(владелец);
    }

    функция ownerOf(uint256 tokenId) переопределение публичного представления возвращает (адрес) {
        владелец адреса = super.ownerOf(tokenId);
        require(msg.sender == owner, "PrivateNFT: msg.sender != owner");
        вернуть владельца;
    }

    функция tokenURI(uint256 tokenId) переопределение публичного представления возвращает (строковую память) {
        владелец адреса = super.ownerOf(tokenId);
        require(msg.sender == owner, "PrivateNFT: msg.sender != owner");
        вернуть super.tokenURI(tokenId);
    }
}
ЭОЛ
echo "Контракт PrivateNFT.sol создан."

echo "Составление контракта..."
npx hardhat компилировать
echo "Контракт составлен."

echo "Создание скрипта deploy.js..."
mkdir -p скрипты
кот <<EOL > скрипты/deploy.js
const hre = require("каска");
const fs = require("fs");

асинхронная функция main() {
  const [deployer] = await hre.ethers.getSigners();
  const contractFactory = await hre.ethers.getContractFactory("PrivateNFT");
  const contract = await contractFactory.deploy(deployer.address);
  ожидание контракта.waitForDeployment();
  const deployedContract = await contract.getAddress();
  fs.writeFileSync("contract.txt", deployedContract);
  console.log(\`Контракт развернут в \${deployedContract}\`);
}

main().catch((ошибка) => {
  консоль.ошибка(ошибка);
  процесс.exitCode = 1;
});
ЭОЛ
echo "скрипт deploy.js создан."

echo "Развертывание контракта..."
npx hardhat запустить скрипты/deploy.js --network swisstronik
echo "Контракт развернут."

echo "Создание скрипта mint.js..."
кот <<EOL > скрипты/mint.js
const hre = require("каска");
const fs = require("fs");
const { encryptDataField, decryptNodeResponse } = require("@swisstronik/utils");

const sendShieldedTransaction = async (подписавший, получатель, данные, значение) => {
  const rpcLink = hre.network.config.url;
  const [encryptedData] = await encryptDataField(rpcLink, data);
  возврат await signer.sendTransaction({
    от: signer.address,
    в: пункт назначения,
    данные: зашифрованныеДанные,
    ценить,
  });
};

асинхронная функция main() {
  const contractAddress = fs.readFileSync("contract.txt", "utf8").trim();
  const [signer] = await hre.ethers.getSigners();
  const contractFactory = await hre.ethers.getContractFactory("PrivateNFT");
  const contract = contractFactory.attach(contractAddress);
  const functionName = "safeMint";
  const safeMintTx = ожидание sendShieldedTransaction(
    подписавший,
    адрес контракта,
    contract.interface.encodeFunctionData(имя_функции, [адрес_подписавшего, 1]),
    0
  );
  await safeMintTx.wait();
  console.log("Квитанция о транзакции: ", \`Минтинг NFT прошел успешно! Хэш транзакции: https://explorer-evm.testnet.swisstronik.com/tx/\${safeMintTx.hash}\`);
}

main().catch((ошибка) => {
  консоль.ошибка(ошибка);
  процесс.exitCode = 1;
});
ЭОЛ
echo "скрипт mint.js создан."

echo "Чистка NFT..."
npx hardhat запустить скрипты/mint.js --network swisstronik
эхо "отчеканено NFT".

echo "Готово! Подписаться: https://t.me/feature_earning"
