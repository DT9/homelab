"""Quick smoke test for Infisical machine identity credentials."""

from __future__ import annotations

import os
import sys

from infisical_sdk import InfisicalSDKClient


REQUIRED_ENV = (
    "INFISICAL_CLIENT_ID",
    "INFISICAL_CLIENT_SECRET",
    "INFISICAL_API_URL",
)


def main() -> int:
    missing = [name for name in REQUIRED_ENV if not os.getenv(name)]
    if missing:
        print(f"Missing required environment variables: {', '.join(missing)}", file=sys.stderr)
        return 2

    api_url = os.environ["INFISICAL_API_URL"].rstrip("/")
    client = InfisicalSDKClient(host=api_url)

    try:
        client.auth.universal_auth.login(
            os.environ["INFISICAL_CLIENT_ID"],
            os.environ["INFISICAL_CLIENT_SECRET"],
        )
    except Exception as exc:  # noqa: BLE001 - we want the raw message
        print(f"Infisical authentication failed: {exc}", file=sys.stderr)
        return 1

    print("Infisical authentication succeeded.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
