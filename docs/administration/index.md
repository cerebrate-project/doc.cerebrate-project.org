# Administration

## Keycloak integration

```mermaid
flowchart LR
    C[Cerebrate] -->|Push data| K[Keycloak]
    K -.->|Provide SSO| BBB[BigBlueButton]
    K -.->|Provide SSO| MM[Mattermost]
    K -.->|Provide SSO| C
```

- Users are **created in Cerebrate** and then **provisioned to Keycloak**
- Other services (including Cerebrate) can **rely on keycloak for authentication** purposes
- **Cerebrate is the user management interface** to create users and revoke their access
    - Keycloak should not be access directly
