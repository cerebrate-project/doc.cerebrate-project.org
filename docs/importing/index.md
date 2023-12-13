# Importing data into Cerebrate using the **importer** CLI tool

Populating Cerebrate with data is straightforward using the built-in **importer** tool available by default on every instance.

## Brief description of the accepted arguments and the configuration file
The command below provides information about the list of accepted options:
```bash
bin/cake Importer --help
```

- `config`: Path to the file describing the mapping between the incoming data and Cerebrate and its format.
- `source`: Source of the data to be imported. Can either accept a valid URL or a filepath.
- `model_class`: Allows to specify the Cerebrate's model in which you want to save the data. Basically, supplying `--model_class Organisations` allows you to create new organisations in the system.
- `primary_key`: Allows to perform data reconciliation to some degree, and thus, avoiding duplicates. If specified, it will join the incoming data with the existing data based on the value taken from this `primary_key`, allowing updates instead of the creation of new entities. A typical use-case would be to use the `uuid` as primary key, or to use the `name` if the former is not available on the incoming dataset.

## Populating brand new data into an empty Cerebrate instance
The simplest use case of the importer is to import organisations from a file on the disk or an URL on an empty Cerebrate instance.

#### Importing new data from a MISP instance
```bash
bin/cake Importer src/Command/config/config-misp-format-organisation.json https://misp.csirt-tooling.org
```

This is what the *config-misp-format-organisation.json* could look like:
```json
{
    "format": "json",
    "mapping": {
        "name": "{n}.Organisation.name",
        "uuid": "{n}.Organisation.uuid",
        "nationality": "{n}.Organisation.nationality"
    },
    "sourceHeaders": {
        "Authorization": "~~YOUR_API_KEY_HERE~~"
    }
}
```
Notice the `sourceHeaders` which can be used to provide authentication information


#### Importing new data from the ENISA CSIRT inventory
```bash
bin/cake Importer src/Command/config/config-enisa-csirts-inventory.json https://www.enisa.europa.eu/topics/csirts-in-europe/csirt-inventory/certs-by-country-interactive-map/tool_data.json
```

This is what the *config-enisa-csirts-inventory.json* could look like:
```json
{
    "format": "json",
    "mapping": {
        "name": "data.{n}.short-team-name",
        "url": "data.{n}.website",
        "contacts": "data.{n}.email",
        "ISO 3166-1 Code": "data.{n}.country-code",
        "website": "data.{n}.website",
        "enisa-geo-group": "data.{n}.enisa-geo-group",
        "is-approved": "data.{n}.is_approved",
        "first-member-type": "data.{n}.first-member-type",
        "team-name": "data.{n}.team-name",
        "oes-coverage": "data.{n}.oes-coverage",
        "enisa-tistatus": "data.{n}.enisa-tistatus",
        "csirt-network-status": "data.{n}.csirt-network-status",
        "constituency": "data.{n}.constituency",
        "establishment": "data.{n}.establishment",
        "email": "data.{n}.email",
        "country-name": "data.{n}.country-name",
        "short-team-name": "data.{n}.short-team-name",
        "key": "data.{n}.key"
    },
    "metaTemplateUUID": "089c68c7-d97e-4f21-a798-159cd10f7864"
}
```
Notice the `metaTemplateUUID` field used to indicates that some fields (such as `enisa-geo-group`) are related to the provided `metaTemplateUUID`.

## Populating data into a Cerebrate instance already containing data
In most of the cases, whenever an import will be done, it will be on an instance already containing data.
In order to avoid duplication of entries and to support update of existing records, the tool must be made aware on how to find records to update.
This can be achieved using the `primary_key` parameter.

### Importing and merging data from the ENISA CSIRT inventory
```bash
bin/cake Importer --primary_key name src/Command/config/config-enisa-csirts-inventory.json https://www.enisa.europa.eu/topics/csirts-in-europe/csirt-inventory/certs-by-country-interactive-map/tool_data.json
```
This is what the *config-enisa-csirts-inventory.json* could look like:
```js
{
    "format": "json",
    "mapping": {
        "name": "data.{n}.short-team-name",
        "url": "data.{n}.website",
        "contacts": "data.{n}.email",
        // [...] same as config showed above
        "email": "data.{n}.email",
        "country-name": {
            "path": "data.{n}.country-name",
            "override": false
        },
        "short-team-name": "data.{n}.short-team-name",
        "key": "data.{n}.key"
    },
    "metaTemplateUUID": "089c68c7-d97e-4f21-a798-159cd10f7864"
}
```

The command above will do the following:
1. Fetch the remote data from the provided URL
2. Fetch existing records from the cerebrate instance
3. Find the matching existing record based on the organisation `name` (coming from `--primary_key name`)  for each entries to be imported
    - Note: If no existing record exists, there is no need for reconciliation and the entry will be created right away. This behavior can be avoided by passing the `--update-only` parameter.
4. Create missing fields and update existing one
    - Note: Notice the slight different mapping for the `country-name`. The `override` flag tells us that this field should not be modified by the imported data

## Use-cases
#### Importing data from MISP and keeping it in sync with ENISA's CSIRT inventory
One very simple use-case of this importer tool would be to keep a cerebrate instance in sync with both a remote MISP instance and the ENISA's CSIRT inventory.
With the correct (already provided) configuration passed to the importer tool, this process becomes trivial.

```bash
# Import data from a MISP instance.
# (--primary_key uuid) No duplication will occur
bin/cake Importer --primary_key uuid --yes /var/www/cerebrate/src/Command/config/config-misp-format-organisation.json https://misp.circl.lu/organisations/index.json

# Sync the cerebrate database with ENISA's CSIRT inventory
# ( --primary_key name) Records reconciliation will be done based on organisation name
# (--update-only) No entries from ENISA's inventory will be ingested if they don't exist in MISP in the first place
bin/cake Importer --primary_key name --update-only --yes src/Command/config/config-enisa-csirts-inventory.json https://www.enisa.europa.eu/topics/csirts-in-europe/csirt-inventory/certs-by-country-interactive-map/tool_data.json
```

#### Importing data from ENISA's CSIRT inventory and overriding Cerebrate's uuid by uuid coming from MISP
This example is the opposite of the one described above. Cerebrate will first ingest data coming from the ENISA's CSIRT inventory and then use MISP's organisation UUID instead of the automatically generated one.

```bash
# Import data from a MISP ENISA's CSIRT inventory
bin/cake Importer --yes src/Command/config/config-enisa-csirts-inventory.json https://www.enisa.europa.eu/topics/csirts-in-europe/csirt-inventory/certs-by-country-interactive-map/tool_data.json

# Sync the UUID
bin/cake Importer --primary_key name --update-only --yes /var/www/cerebrate/src/Command/config/config-misp-format-organisation.json https://misp.circl.lu/organisations/index.json
```
## Limitation
One limitation of the importer tool lies in how the existing data and incoming data is joined. Currently the join point is done through a strict string match on the value extracted from the `primary_key` field. That leads the tool to skip slightly different entries even though they are the same. For example, if cerebrate has an organisation record `CERT EU` and the incoming data refers to that exact same organisation as `CERT-EU`, there will be no match and the entry will be skipped.

# Overriding data in Cerebrate using the **FieldSquasher** CLI tool
Even though the **importer** CLI tool support a lightweight method to override data thanks to the `primary_key` argument, the primary goal of the tool is to new data into cerebrate. The purpose of the **FieldSquasher** tool is to override specific fields but it features a more flexible way to join existing data with the incoming data.

## Explained example of a configuration file
```js
{
    "source": "data.json",          // Source from which the data should be taken. Can be either a path or URL
    "finder": {                     // Config describing how to reach the record and how to join data
        "path": "{n}.Organisation", // Path to join each record
        "joinFields": {             
            "squashed": "name",     // Path for the left part of the join (data existing in cerebrate) 
            "squashing": "name"     // Path for the right part of the join (data coming from the source)
        },
        "type": "closest",          // Method to perform the join. Accept `exact` for exact string match or `closest` for a levenshtein distance
        "levenshteinScore": 1       // The levenshtein threshold under which data will be joined
    },
    "target": {
        "model": "Organisations",   // Model under which the tool operating on
        "squashedField": "uuid"     // The field about to be overridden
    },
    "squashingData": {
        "squashingField": "uuid",   // Path to access the overriding value from the record (finder.path)
        "massage": "validateUUID"   // Optional function to be called to modify the data before the override
    }
}
```

By passing such configuration, difference such as `cert eu` and `cert-eu` will be detected and joined nonetheless.

It should be noted that for very small strings, error could happen. For example, `cert.lu` and `cert.eu` will both have a levenshtein score of 1 and thus be joined. To avoid accidentally saving such errors, the tool propose to dump on the disk the different steps taken so that admin can later check that everything went as intended and recover mistakes manually if needed.


# Generating summaries
The CLI command `Summary` can be used to generate summaries about changes done for the provided amount of days.
It will create a `txt` file in the `/tmp` directory for all organisation nationalities (or only for the given one).
Each `txt` files will contain changes for the following data:
- Organisations
- Individuals
- Users

## Usage
```bash
$ bin/cake Summary --help

Usage:
cake summary [-d 7] [-h] [-q] [-v] [<nationality>]

Options:

--days, -d     The amount of days to look back in the logs
               (default: 7)
--help, -h     Display this help.
--output, -o   The destination folder where to write the files
               (default: /tmp)
--quiet, -q    Enable quiet output.
--verbose, -v  Enable verbose output.

Arguments:

nationality  The organisation nationality. (optional)
```

## Example

```bash
$ bin/cake Summary Luxembourg -o /tmp/countries
$ cat /tmp/countries/Luxembourg.txt 
Modified users:
Model,Action,"Editor user","Log ID",Datetime,Change
Users,add,"admin (1)",1187,"2022-11-14 09:18:27","{""username"":""johndoe"",""organisation_id"":2,""role_id"":3,""individual_id"":4,""created"":""2022-11-14T09:18:27+00:00"",""uuid"":""27b5390c-8a44-4c67-954e-c74fdd21fa88""}"
Users,add,"admin (1)",1192,"2022-11-14 09:24:40","{""username"":""johndoe2"",""organisation_id"":2,""role_id"":2,""individual_id"":5,""created"":""2022-11-14T09:24:40+00:00"",""uuid"":""3cdc960e-1bdc-463f-9f2f-dd780ca22f81""}"
Users,add,"admin (1)",1195,"2022-11-14 09:37:58","{""username"":""johndoe3"",""organisation_id"":2,""role_id"":2,""individual_id"":6,""created"":""2022-11-14T09:37:58+00:00"",""uuid"":""c54bf116-549c-4828-958f-05e12cfaa76b""}"
...

Modified organisations:
Model,Action,"Editor user","Log ID",Datetime,Change
Organisations,edit,"admin (1)",1188,"2022-11-14 09:23:30","{""nationality"":["""",""Luxembourg""]}"
Organisations,edit,"admin (1)",1189,"2022-11-14 09:24:06","{""nationality"":[""Luxembourg"",""""]}"
Organisations,edit,"admin (1)",1303,"2022-11-15 10:38:19","{""nationality"":["""",""Luxembourg""]}"
...

Modified individuals:
Model,Action,"Editor user","Log ID",Datetime,Change
Individuals,add,"admin (1)",1185,"2022-11-14 09:18:27","{""email"":""john.doe@my-fake-org.com"",""first_name"":""John"",""last_name"":""Doe"",""uuid"":""39369a66-6d0f-461a-ae99-f9450c8839c8"",""created"":""2022-11-14T09:18:27+00:00""}"
Individuals,add,"admin (1)",1190,"2022-11-14 09:24:40","{""email"":""john.doe2@my-fake-org.com"",""first_name"":""John2"",""last_name"":""Doe2"",""uuid"":""b56c5435-4f45-4848-ba24-568ff9004cba"",""created"":""2022-11-14T09:24:40+00:00""}"
Individuals,add,"admin (1)",1193,"2022-11-14 09:37:58","{""email"":""john.doe3@my-fake-org.com"",""first_name"":""John3"",""last_name"":""Doe3"",
...
```

Afterward, these files can, for example, be sent by email using the following script
```bash
#!/usr/bin/bash

path="/home/john/books"
mail_subject="Periodic summary"
email_address="john.doe@example.test"

for filename in $path/*.txt; do
    mail -a "$filename" -s "$mail_subject" "$email_address" < /dev/null 
done
```
