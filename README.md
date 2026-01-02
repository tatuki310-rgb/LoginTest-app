# AWS Cognito with Google IdP Implementation Guide

このプロジェクトは、Java (Spring Boot) とAWS Cognitoを使用して、Googleアカウントでのログイン機能を実装したサンプルアプリケーションです。

## 前提条件

- AWS アカウント
- Google Cloud Platform (GCP) アカウント
- Java 17+
- Maven

## 設定手順

アプリケーションを動作させるためには、以下の設定を行う必要があります。

### 1. Google Cloud Platform (GCP) の設定

1. **プロジェクトの作成**: GCPコンソールで新しいプロジェクトを作成します。
2. **OAuth同意画面の設定**:
   - [APIとサービス] > [OAuth同意画面] に移動します。
   - `User Type` を選択（通常は `外部`）し、作成します。
   - アプリ名、ユーザーサポートメールなどを入力します。
3. **認証情報の作成**:
   - [認証情報] > [認証情報を作成] > [OAuth クライアント ID] を選択します。
   - アプリケーションの種類: `ウェブ アプリケーション`
   - 名前: 任意の名前（例: `Cognito Integration`）
   - **承認済みのリダイレクト URI**:
     - この時点では、AWS Cognitoのドメインが決まっていないため、一旦空欄にするか、後で設定するCognitoのドメインを入力する必要があります（例: `https://<your-cognito-domain>.auth.<region>.amazoncognito.com/oauth2/idpresponse`）。
   - 作成後、表示される **クライアントID** と **クライアントシークレット** をメモします。

### 2. AWS Cognito の設定

1. **ユーザープールの作成**:
   - AWSコンソールでCognitoを開き、「ユーザープールを作成」を選択します。
   - 認証プロバイダー: `Google` を選択します。
   - 先ほどGCPで取得した **クライアントID** と **クライアントシークレット** を入力します。
2. **アプリクライアントの作成**:
   - ユーザープール作成ウィザードの中で、または作成後に「アプリケーションの統合」タブから「アプリクライアント」を作成します。
   - **クライアントシークレット**を生成するように設定してください。
3. **ドメインの設定**:
   - 「アプリケーションの統合」タブで「Cognitoドメイン」を設定します（例: `my-app-login`）。
   - このドメインを使用して、GCPの「承認済みのリダイレクト URI」を更新してください:
     `https://<your-domain-prefix>.auth.<region>.amazoncognito.com/oauth2/idpresponse`
4. **ホストされたUIの設定**:
   - アプリクライアントの設定で「ホストされたUI」を編集します。
   - **許可されているコールバック URL**: `http://localhost:8080/login/oauth2/code/cognito`
   - **許可されているサインアウト URL**: `http://localhost:8080/`
   - **IDプロバイダ**: `Google` を選択します。
   - **OAuth 2.0 権限タイプ**: `Authorization code grant`
   - **OpenID Connect スコープ**: `email`, `openid`, `profile`

### 3. アプリケーションの設定 (`application.yml`)

`src/main/resources/application.yml` を開き、以下の値を設定してください。

- `COGNITO_CLIENT_ID`: AWS CognitoのアプリクライアントID
- `COGNITO_CLIENT_SECRET`: AWS Cognitoのアプリクライアントシークレット
- `issuer-uri`: `https://cognito-idp.<region>.amazonaws.com/<pool-id>`
  - `<region>`: AWSリージョン (例: `ap-northeast-1`)
  - `<pool-id>`: ユーザープールID

環境変数として設定することも可能です：

```bash
export COGNITO_CLIENT_ID=your_client_id
export COGNITO_CLIENT_SECRET=your_client_secret
```

## 実行方法

```bash
mvn spring-boot:run
```

ブラウザで `http://localhost:8080` にアクセスすると、ログイン画面が表示されます。
