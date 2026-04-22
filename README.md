# AWS 2-Tier Architecture Portfolio (Terraform)

## 概要
AWS上にWebサーバー（EC2）とDBサーバー（RDS）を分離した2層構成のインフラをTerraformで構築したポートフォリオです。  
インフラの再現性・可搬性を意識し、Infrastructure as Code（IaC）で構築しています。

---

## 構成図
![architecture](./architecture.svg)

---

## 使用技術
- AWS
  - VPC
  - EC2
  - RDS (MySQL 8.0)
  - Subnet (Public / Private)
  - Internet Gateway
  - Route Table
  - Security Group
- Terraform
- Linux (Amazon Linux 2)
- MySQL 8.0

---

## アーキテクチャ構成

### ネットワーク構成
- VPC：10.1.0.0/16
- Public Subnet：Webサーバー配置
- Private Subnet：RDS配置（外部非公開）

### 通信構成
Internet → EC2（Webサーバー）→ RDS（DB）

---

## セキュリティ設計
- RDSをPrivate Subnetに配置し外部から直接アクセス不可
- Security Groupで最小限の通信のみ許可
  - SSH：特定IPのみ許可
  - HTTP：全公開
  - MySQL：EC2からのみ許可
- 最小権限の原則に基づいた設計

---

## 構築手順
```bash
terraform init
terraform plan
terraform apply
