CREATE TABLE `Users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(225),
  `email` VARCHAR(225),
  `createddate` DATE
);

CREATE TABLE `Business` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `id` INT AUTO_INCREMENT,
  `name` VARCHAR(255),
  `address` VARCHAR(255),
  `createddate` DATE,
  FOREIGN KEY (`id`) REFERENCES `Users`(`id`)
);

