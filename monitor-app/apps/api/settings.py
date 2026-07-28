from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Amazon Infra Monitor"
    app_version: str = "0.0.1"
    app_host: str = "127.0.0.1"
    app_port: int = 8005
    cors_origins: str = "http://localhost:4005,http://127.0.0.1:4005"
    monitor_services: str = "nginx"
    monitor_ports: str = "80:Nginx HTTP,443:Nginx HTTPS,4005:Amazon Infra Monitor Web,8005:Amazon Infra Monitor API"
    monitor_urls: str = ""
    monitor_timeout_seconds: float = 2.0
    oracle_enabled: bool = False
    oracle_user: str = ""
    oracle_password: str = ""
    oracle_dsn: str = ""
    oracle_wallet_location: str = ""
    oracle_wallet_password: str = ""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @staticmethod
    def _csv(value: str) -> list[str]:
        return [item.strip() for item in value.split(",") if item.strip()]

    @property
    def cors_origin_list(self) -> list[str]:
        return self._csv(self.cors_origins)

    @property
    def service_list(self) -> list[str]:
        return self._csv(self.monitor_services)

    @property
    def port_list(self) -> list[tuple[int, str]]:
        known_names = {
            80: "Nginx HTTP",
            443: "Nginx HTTPS",
            4001: "Orbital App Web",
            4002: "Station App Web",
            4003: "Inst App Web",
            4005: "Amazon Infra Monitor Web",
            8001: "Orbital App API",
            8002: "Station App API",
            8003: "Inst App API",
            8005: "Amazon Infra Monitor API",
        }
        targets = []
        for item in self._csv(self.monitor_ports):
            port_text, separator, configured_name = item.partition(":")
            port = int(port_text)
            name = configured_name.strip() if separator and configured_name.strip() else known_names.get(port, f"Porta {port}")
            targets.append((port, name))
        return targets

    @property
    def url_list(self) -> list[str]:
        return self._csv(self.monitor_urls)


@lru_cache
def get_settings() -> Settings:
    return Settings()
