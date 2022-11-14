# Auditing

Cerebrate includes a powerful and exhaustive model for auditing all activities taking place in Cerebrate.

To access the audit log via the user interface, under the `administration` section and `instance` part, there is an `Audit Logs`.

![](/assets/screenshots/auditlogs.png)

## Logs

Then a logs view is accessible which includes the following:

- An `id` reference to the log
!!! info inline end
    A source IP can be the one from the proxy if the `X-Forwarded-For` is not set.
- A source IP address which performs the change
- The associated `Username` which performs the update
- A `Title` which includes a summary of the change
- A `Model` where the change was performed and a associated `Model ID` 
- An `Action` such as login, add, delete.
- A complete entry called `Changed` which includes the complete change audited

![](/assets/screenshots/auditview.png)

## Filtering

All the columns can be displayed or removed from the view by accessing the right slider:

![](/assets/screenshots/auditcolview.png)

## Searching

A search fields (on top right) allow to search for `model`,`mode_title` and `request_action`:

![](/assets/screenshots/auditsearch.png)
