# 1. ビルド環境 (MavenとJDKが入ったコンテナ)
FROM maven:3.9-amazoncorretto-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
# テストは一旦スキップしてビルド (本番運用ではテスト推奨)
RUN mvn clean package -DskipTests

# 2. 実行環境 (JDKのみの軽量コンテナ)
FROM amazoncorretto:17
WORKDIR /app
# ビルド環境で作ったjarファイルをコピー
COPY --from=build /app/target/*.jar app.jar
# ポート8080を開放
EXPOSE 8080
# 起動コマンド
ENTRYPOINT ["java", "-jar", "app.jar"]