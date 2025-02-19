---
Title: Installation Guide
weight: 60
---

{{% notice note %}}
The following documentation is for SuiteCRM Version 8+;
{{% /notice %}}

== Version
=== SuiteCRM 8.8.x



# Developer Mode
SuiteCRM will cache various files that it processes, such as Smarty templates. Developer mode will turn off some of the caching so that changes to files will be seen immediately (though this isn’t always the case - as is the case with extensions). This can be enabled either through the config file or via the General settings page inside admin.

# Log Level
The default log level of SuiteCRM is fatal. This is a good default for production instances but you may want to increase the log level to info or debug. This will make the log output more verbose so, should anything go wrong, you’ll have something to refer to. See the chapter on logging for more information.

# Display errors
You’ll also want to turn off display errors. Unfortunately at the moment SuiteCRM has various notices and warnings out of the box. With display_errors on this can sometimes cause AJAX pages and the link to break.

With this being said you should be checking the PHP error logs or selectively enabling
display_errors to ensure that the code you are creating is not creating additional notices, warnings or errors.

# XDebug
XDebug is a PHP extension which provides profiling and debugging capabilities to PHP. This can massively improve developer productivity by simplifying development and, particularly, tracking down any issues. See the XDebug site for information on XDebug. 

=== Files to create

.
├── Dockerfile
└── conf
    ├── apache
    │   ├── apache.conf
    │   └── vhost.conf
    ├── cron-suitecrm
    ├── entrypoint.sh
    └── php
        ├── php.conf
        └── php.ini



---
weight: 2
title: "SuiteCRM Directory Structure"
---

= 2. SuiteCRM Directory Structure

`cache`::
  Contains cache files used by SuiteCRM including compiled smarty
  templates, grouped vardefs, minified and grouped JavaScript. Some
  modules and custom modules may also store (temporary) module specific
  info here.
`custom`::
  Contains user and developer customisations to SuiteCRM. Also contains
  some SuiteCRM code to maintain compatibility with SugarCRM. However
  this is likely to change in the future.
`data`::
  Stores the classes and files used to deal with SugarBeans and their
  relationships.
`examples`::
  Contains a few basic examples of lead capture and API usage. However
  these are very outdated.
`include`::
  Contains the bulk of non module and non data SuiteCRM code.
`install`::
  Code used by the SuiteCRM installer.
`jssource`::
  The `jssource` folder contains the unminified source of some of the
  JavaScript files used within SuiteCRM.
`metadata`::
  Stores relationship metadata for the various stock SuiteCRM modules.
  This should not be confused with module metadata which contains
  information on view, dashlet and search definitions.
`ModuleInstall`::
  Code for the module installer.
`modules`::
  Contains the code for any stock or custom SuiteCRM modules.
`service`::
  Code for the SuiteCRM Soap and REST APIs.
`themes`::
  Code, data and images for the bundled SuiteCRM theme.
`upload`::
  The `upload` folder contains documents that have been uploaded to
  SuiteCRM. The names of the files comes from the ID of the matching
  Document Revision/Note. `upload`/`upgrades` will also contain various
  upgrade files and the packages of installed modules.
 `log4php`, `soap`, `XTemplate`, `Zend` ::
  Source code for various libraries used by SuiteCRM some of which are
  deprecated. link:../suitecrm-directory-structure[↩]


---
weight: 3
title: "Working with Beans"
---

:toc:

= 3. Working with Beans

Beans are the Model in SuiteCRM’s MVC (Model View Controller)
architecture. They allow retrieving data from the database as objects
and allow persisting and editing records. This section will go over the
various ways of working with beans.

== The BeanFactory

The BeanFactory allows dynamically loading bean instances or creating
new records. For example to create a new bean you can use:

.Example 3.1: Creating a new Bean using the BeanFactory
[source,php]
----
$bean = BeanFactory::newBean('<TheModule>');
//For example a new account bean:
$accountBean = BeanFactory::newBean('Accounts');
----


Retrieving an existing bean can be achieved in a similar manner:

.Example 3.2: Retrieving a bean with the BeanFactory
[source,php]
----
$bean = BeanFactory::getBean('<TheModule>', $beanId);
//For example to retrieve an account id
$bean = BeanFactory::getBean('Accounts', $beanId);
----



`getBean` will return an unpopulated bean object if `$beanId` is not
supplied or if there’s no such record. Retrieving an unpopulated bean
can be useful if you wish to use the static methods of the bean (for
example see the Searching for Beans section). To deliberately retrieve
an unpopulated bean you can omit the second argument of the `getBean`
call. I.e.

.Example 3.3: Retrieving an unpopulated bean
[source,php]
$bean = BeanFactory::getBean('<TheModule>');



{{% notice warning %}}
`BeanFactory::getBean` caches ten results. This can cause odd behaviour
if you call `getBean` again and get a cached copy. Any calls that return
a cached copy will return the same instance. This means changes to one
of the beans will be reflected in all the results.
{{% /notice %}}



Using BeanFactory ensures that the bean is correctly set up and the
necessary files are included etc.

== SugarBean

The SugarBean is the parent bean class and all beans in SuiteCRM extend
this class. It provides various ways of retrieving and interacting with
records.

== Searching for beans

The following examples show how to search for beans using a bean class.
The examples provided assume that an account bean is available names
$accountBean. This may have been retrieved using the getBean call
mentioned in the BeanFactory section e.g.

.Example 3.4: Retrieving an unpopulated account bean
[source,php]
$accountBean = BeanFactory::getBean('Accounts');

=== get_list

The get_list method allows getting a list of matching beans and allows
paginating the results.

.Example 3.5: get_list method signature
[source,php]
----
get_list(
    $order_by = "",
    $where = "",
    $row_offset = 0,
    $limit=-1,
    $max=-1,
    $show_deleted = 0)
----



`$order_by`::
  Controls the ordering of the returned list. `$order_by` is specified
  as a string that will be used in the SQL ORDER BY clause e.g. to sort
  by name you can simply pass `name`, to sort by date_entered descending
  use `date_entered DESC`. You can also sort by multiple fields. For
  example sorting by date_modified and id descending
  `date_modified, id DESC`.
`$where`::
  Allows filtering the results using an SQL WHERE clause. `$where`
  should be a string containing the SQL conditions. For example in the
  contacts module searching for contacts with specific first names we
  might use `contacts.first_name='Jim'`. Note that we specify the table,
  the query may end up joining onto other tables so we want to ensure
  that there is no ambiguity in which field we target.
`$row_offset`::
  The row to start from. Can be used to paginate the results.
`$limit`::
  The maximum number of records to be returned by the query. -1 means no
  limit.
`$max`::
  The maximum number of entries to be returned per page. -1 means the
  default max (usually 20).
`$show_deleted`::
  Whether to include deleted results.

==== Results
get_list will return an array. This will contain the paging information
and will also contain the list of beans. This array will contain the
following keys:

`list`::
  An array of the beans returned by the list query
`row_count`::
  The total number of rows in the result
`next_offset`::
  The offset to be used for the next page or -1 if there are no further
  pages.
`previous_offset`::
  The offset to be used for the previous page or -1 if this is the first
  page.
`current_offset`::
  The offset used for the current results.

==== Example
Let’s look at a concrete example. We will return the third page of all
accounts with the industry `Media` using 10 as a page size and ordered
by name.

.Example 3.6: Example get_list call
[source,php]
----
$beanList = $accountBean->get_list(
                                //Order by the accounts name
                                'name',
                                //Only accounts with industry 'Media'
                                "accounts.industry = 'Media'",
                                //Start with the 30th record (third page)
                                30,
                                //No limit - will default to max page size
                                -1,
                                //10 items per page
);
----



This will return:

.Example 3.7: Example get_list results
[source,php]
----
Array
(
    //Snipped for brevity - the list of Account SugarBeans
    [list] => Array()
    //The total number of results
    [row_count] => 36
    //This is the last page so the next offset is -1
    [next_offset] => -1
    //Previous page offset
    [previous_offset] => 20
    //The offset used for these results
    [current_offset] => 30
)
----


=== get_full_list

`get_list` is useful when you need paginated results. However if you are
just interested in getting a list of all matching beans you can use
`get_full_list`. The `get_full_list` method signature looks like this:

.Example 3.8: get_full_list method signature
[source,php]
----
get_full_list(
            $order_by = "",
            $where = "",
            $check_dates=false,
            $show_deleted = 0
----

These arguments are identical to their usage in `get_list` the only
difference is the `$check_dates` argument. This is used to indicate
whether the date fields should be converted to their display values
(i.e. converted to the users date format).

==== Results
The get_full_list call simply returns an array of the matching beans

==== Example
Let’s rework our `get_list` example to get the full list of matching
accounts:

.Example 3.9: Example get_full_list call
[source,php]
----
$beanList = $accountBean->get_full_list(
                                //Order by the accounts name
                                'name',
                                //Only accounts with industry 'Media'
                                "accounts.industry = 'Media'"
                                );
----



=== retrieve_by_string_fields

Sometimes you only want to retrieve one row but may not have the id of
the record. `retrieve_by_string_fields` allows retrieving a single
record based on matching string fields.

.Example 3.10: retrieve_by_string_fields method signature
[source,php]
----
retrieve_by_string_fields(
                          $fields_array,
                          $encode=true,
                          $deleted=true)
----



`$fields_array`::
  An array of field names to the desired value.
`$encode`::
  Whether or not the results should be HTML encoded.
`$deleted`::
  Whether or not to add the deleted filter.

{{% notice note %}}
Note here that,
confusingly, the deleted flag works differently to the other methods we
have looked at. It flags whether or not we should filter out deleted
results. So if true is passed then the deleted results will _not_ be
included.
{{% /notice %}}

==== Results
retrieve_by_string_fields returns a single bean as it’s result or null
if there was no matching bean.

==== Example
For example to retrieve the account with name `Tortoise Corp` and
account_type `Customer` we could use the following:

.Example 3.11: Example retrieve_by_string_fields call
[source,php]
----
$beanList = $accountBean->retrieve_by_string_fields(
                                array(
                                  'name' => 'Tortoise Corp',
                                  'account_type' => 'Customer'
                                )
                              );
----



== Accessing fields

If you have used one of the above methods we now have a bean record.
This bean represents the record that we have retrieved. We can access
the fields of that record by simply accessing properties on the bean
just like any other PHP object. Similarly we can use property access to
set the values of beans. Some examples are as follows:

.Example 3.12: Accessing fields examples
[source,php]
----
//Get the Name field on account bean
$accountBean->name;
 
//Get the Meeting start date
$meetingBean->date_start;
 
//Get a custom field on a case
$caseBean->third_party_code_c;
 
//Set the name of a case
$caseBean->name = 'New Case name';
 
//Set the billing address post code of an account
$accountBean->billing_address_postalcode = '12345';
----



When changes are made to a bean instance they are not immediately
persisted. We can save the changes to the database with a call to the
beans `save` method. Likewise a call to `save` on a brand new bean will
add that record to the database:

.Example 3.13: Persisting bean changes
[source,php]
----
//Get the Name field on account bean
$accountBean->name = 'New account name';
//Set the billing address post code of an account
$accountBean->billing_address_postalcode = '12345';
//Save both changes.
$accountBean->save();
 
//Create a new case (see the BeanFactory section)
$caseBean = BeanFactory::newBean('Cases');
//Give it a name and save
$caseBean->name = 'New Case name';
$caseBean->save();
----


{{% notice info %}}
Whether to
save or update a bean is decided by checking the `id` field of the bean.
If `id` is set then SuiteCRM will attempt to perform an update. If there
is no `id` then one will be generated and a new record will be inserted
into the database. If for some reason you have supplied an `id` but the
record is new (perhaps in a custom import script) then you can set
`new_with_id` to true on the bean to let SuiteCRM know that this record
is new.
{{% /notice %}}

== Marking a Bean as deleted

Use the `mark_deleted` method for this. It will set the `deleted` field to `1`, also mark any relationships of that Bean 
as deleted, and remove the reference to that item from the **Recently viewed** lists.

[source,php]
----
$bean->mark_deleted($id);

// Saving is required afterwards
$bean->save();
----

This method will also call the appropriate `before_delete` and `after_delete` logic hooks.

== Related beans

We have seen how to save single records but, in a CRM system,
relationships between records are as important as the records
themselves. For example an account may have a list of cases associated
with it, a contact will have an account that it falls under etc. We can
get and set relationships between beans using several methods.

=== get_linked_beans

The `get_linked_beans` method allows retrieving a list of related beans
for a given record.

.Example 3.14: get_linked_beans method signature
[source,php]
----
get_linked_beans(
                $field_name,
                $bean_name = '',
                $order_by = '',
                $begin_index = 0,
                $end_index = -1,
                $deleted = 0,
                $optional_where = "");
----



`$field_name`::
  The link field name for this link. Note that this is not the same as
  the name of the relationship. If you are unsure of what this should be
  you can take a look into the cached vardefs of a module in
  `cache/modules/<TheModule>/<TheModule>Vardefs.php` for the link
  definition.
`$bean_name`::
  Used to specify the bean name of the beans you are expecting back. Not needed in current versions, kept for backward 
  compatibility or for the unlikely event you have an old style relationship.
`$order_by`::
  Optionally, add a clause like `last_name DESC` to get sorted results (only available from SuiteCRM 7.4 onwards).
`$begin_index`::
  Skips the initial `$begin_index` results. Can be used to paginate.
`$end_index`::
  Return up to the `$end_index` result. Can be used to paginate.
`$deleted`::
  Controls whether deleted or non deleted records are shown. If true
  only deleted records will be returned. If false only non deleted
  records will be returned.
`$optional_where`::
  Allows filtering the results using an SQL WHERE clause. See the
  `get_list` method for more details.

==== Results
`get_linked_beans` returns an array of the linked beans.

.Example 3.15: Example get_linked_beans call
[source,php]
----
$accountBean->get_linked_beans(
                'contacts',
                'Contacts',
                array(),
                0,
                10,
                0,
                "contacts.primary_address_country = 'USA'");
----



=== Relationships

In addition to the `get_linked_beans` call you can also load and access
the relationships more directly.

==== Loading
Before accessing a relationship you must use the `load_relationship`
call to ensure it is available. This call takes the link name of the
relationship (not the name of the relationship). As mentioned previously
you can find the name of the link in
`cache/modules/<TheModule>/<TheModule>Vardefs.php` if you’re not sure.

.Example 3.16: Loading a relationship
[source,php]
----
//Load the relationship
$accountBean->load_relationship('contacts');
//Can now call methods on the relationship object:
$contactIds = $accountBean->contacts->get();
----




==== Methods

`get` ::
Returns the ids of the related records in this relationship e.g for the
account - contacts relationship in the example above it will return the
list of ids for contacts associated with the account.

`getBeans` ::
Similar to `get` but returns an array of beans instead of just ids.

{{% notice warning %}}
`getBeans` will
load the full bean for each related record. This may cause poor
performance for relationships with a large number of beans.
{{% /notice %}}

`add` ::
Allows relating records to the current bean. `add` takes a single id or
bean or an array of ids or beans. If the bean is available this should
be used since it prevents reloading the bean. For example to add a
contact to the relationship in our example we can do the following:

.Example 3.18: Adding a new contact to a relationship
[source,php]
----
//Load the relationship
$accountBean->load_relationship('contacts');
 
//Create a new demo contact
$contactBean = BeanFactory::newBean('Contacts');
$contactBean->first_name = 'Jim';
$contactBean->last_name = 'Mackin';
$contactBean->save();
 
//Link the bean to $accountBean
$accountBean->contacts->add($contactBean);
----




`delete` ::
`delete` allows unrelating beans. Counter-intuitively it accepts the ids
of both the bean and the related bean. For the related bean you should
pass the bean if it is available e.g when unrelating an account and
contact:

.Example 3.19: Removing a new contact from a relationship
[source,php]
----
//Load the relationship
$accountBean->load_relationship('contacts');

//Unlink the contact from the account - assumes $contactBean is a Contact SugarBean
$accountBean->contacts->delete($accountBean->id, $contactBean);
----


{{% notice warning %}}
Be careful with the delete method. Omitting the second argument will cause all relationships
for this bean to be removed.
{{% /notice %}}



---
weight: 10
title: "Config"
---

= 10. Config

== The config files

There are two main config files in SuiteCRM, both of which are in the
root SuiteCRM folder. These are `config.php` and `config_override.php`.
The definitions in here provide various configuration options for
SuiteCRM. All the way from the details used to access the database to
how many entries to show per page in the list view. Most of these
options are accessible from the SuiteCRM administration page. However
some are only definable in the config files.

=== config.php

This is the main SuiteCRM config file and includes important information
like the database settings and the current SuiteCRM version.

Generally settings in this file wont be changed by hand. An exception to
this is if SuiteCRM has been moved or migrated. In which case you may
need to change the database settings and the site_url. Let’s look at the
database settings first:

.Example 10.1: Database config definition
[source,php]
----
'dbconfig' =>
array (
   'db_host_name' => 'localhost',
   'db_host_instance' => 'SQLEXPRESS',
   'db_user_name' => 'dbuser',
   'db_password' => 'dbpass',
   'db_name' => 'dbname',
   'db_type' => 'mysql',
   'db_port' => '',
   'db_manager' => 'MysqliManager',
),
----



Here we can see this instance is setup to access a local MySQL instance
using the username/password dbuser/dbpass and accessing the database
named ‘dbname’.

The site url settings are even simpler:

.Example 10.2: Setting the site URL
[source,php]
'site_url' => 'http://example.com/suitecrm',



The site url for the above is simply ‘http://example.com/suitecrm’ if we
were moving this instance to, for example, suite.example.org, then we
can simply place that value in the file.

These are generally the only two instances where you would directly
change `config.php`. For other changes you would either make the change
through SuiteCRM itself or you would use the `config_override.php` file.

=== config_override.php

`config_override.php` allows you to make config changes without risking
breaking the main config file. This is achieved quite simply by adding,
editing or removing items from the $sugar_config variable. The
`config_override.php` file will be merged with the existing config
allowing, as the name suggests, overriding the config. For example in
config_override.php we can add our own, new, config item:

.Example 10.3: Adding a custom config value
[source,php]
$sugar_config['enable_the_awesome'] = true;



or we can edit an existing config option in a very similar manner by
simply overwriting it:

.Example 10.4: Overwriting an existing config value
[source,php]
$sugar_config['logger']['level'] = 'debug';



== Using config options

We may want to access config options in custom code (or as detailed
above if we have created our own config setting we may want to use
that). We can easily get the config using the php global keyword:

.Example 10.5: Accessing a config setting within SuiteCRM
[source,php]
----
function myCustomLogic(){
  //Get access to config
  global $sugar_config;
  //use the config values
  if(!empty($sugar_config['enable_the_awesome'])){
    doTheAwesome();
  }
}
----


---
weight: 11
title: "Logging"
---

= 11. Logging

== Logging messages

Logging in SuiteCRM is achieved by accessing the log singleton. Accessing
an instance of the logger is as simple as:

.Example 11.1: Accessing the log
[source,php]
LoggerManager::getLogger();



This can then be used to log a message. Each log level is available as a
method. For example:

.Example 11.2: Logging messages
[source,php]
----
LoggerManager::getLogger()->debug('This is a debug message');
LoggerManager::getLogger()->error('This is an error message');
----



This will produce the following output:

.Example 11.3: Logging messages example output
[source,php]
----
Tue Apr 28 16:52:21 2015 [15006][1][DEBUG] This is a debug message
Tue Apr 28 16:52:21 2015 [15006][1][ERROR] This is an error message
----


== Logging output

The logging output displays the following information by default:

.Example 11.4: Logging messages example output
[source,php]
<Date> [<ProcessId>][<UserId>][<LogLevel>] <LogMessage>



`<Date>`::
  The date and time that the message was logged.
`<ProcessId>`::
  The PHP process id.
`<UserId>`::
  The ID of the user that is logged into SuiteCRM.
`<LogLevel>`::
  The log level for this log message.
`<LogMessage>`::
  The contents of the log message.

== Log levels

Depending on the level setting in admin some messages will not be added
to the log e.g if your logger is set to `error` then you will only see
log levels of `error` or higher (`error`, `fatal` and `security`).

The default log levels (in order of verbosity) are:

* `debug`
* `info`
* `warn`
* `deprecated`
* `error`
* `fatal`
* `security`

{{% notice note %}}
Generally on a production instance you will use the less verbose levels
(probably `error` or `fatal`). However whilst you are developing you can
use whatever level you prefer. I prefer the most verbose level -
`debug`. 
{{% /notice %}}

== Log file location

The log file, by default, is called `suitecrm.log` and resides in your installation's root directory. 

But you can change log settings through the UI, under link:../../admin/administration-panel/system/#_logger_settings[Admin / System settings / Logger Settings].



---
title: Downloading & Installing
weight: 20
---


{{% notice info %}}
The following documentation is for SuiteCRM Version 8+
{{% /notice %}}


== 1. Setup Web Server

The first step to take is to setup the webserver.

---
title: "Webserver Setup Guide"
weight: 21
---

{{% notice info %}}
The following documentation is for SuiteCRM Version 8+; to see documentation for Version 7, click link:../../../../developer/introduction[here].
{{% /notice %}}

== 1. Intro

This guide contains the steps required to setup a webserver for installing SuiteCRM 8+

{{% notice note %}}
The following documentation will use as base setup a LAMP stack: Linux, Apache, MySql and php. However, most of the steps may apply to other webservers and databases
{{% /notice %}}

== 2. Install required software

Install the platform-appropriate version of the following:

* webserver: `apache`
* `php`
* database: `mysql` or `mariadb`

{{% notice info %}}
See the link:../../compatibility-matrix/[Compatibility matrix] to ensure you have the correct versions of the required software.
There are other software dependencies on the Compatibility matrix under the `Additional requirements for Development` section,
however those are the ones required for a development environment.
{{% /notice %}}

When installing SuiteCRM from pre-build installable package zip you **do not** need to install the dependencies that are for development, namely: node, angular cli, yarn/npm.

The SuiteCRM 8 pre-built installable package zip comes with the pre-built front end files under `public/dist` and all the required libs on vendors.

=== Helpful Resources

On how to install a development LAMP stack on Ubuntu:

* link:https://www.digitalocean.com/community/tutorials/how-to-install-php-7-4-and-set-up-a-local-development-environment-on-ubuntu-20-04[DigitalOcean - Tutorial on how to install LAMP development environment,window=_blank]


== 3. Install required php modules

Install on your server the required php modules:

* cli
* curl
* common
* intl
* json
* gd
* mbstring
* mysqli
* pdo_mysql
* openssl
* soap
* xml
* zip
* imap (optional)
* ldap (optional)

=== Helpful Resources

Please check the `Helpful Resources` section from link:#_2_install_required_software[Install required software] for instructions on how to install php modules

== 4. Configuring URL re-writes

In order for api routes to work you need allow url re-writes.

* All SuiteCRM-Core api calls depend on this (calls to `api/graphql`) if re-rewrites are not allowed you will get a `404` when calling the api.

In `apache` webserver this can be achieved by enabling mod-rewrite and configuring the vhost.

{{% notice note %}}
It is highly recommended that you update the webroot or configure vhost to point to the `public` folder inside SuiteCRM folder. If the webroot is pointing to SuiteCRM folder instead of the public folder, all the files under SuiteCRM folder maybe be exposed to the web.
{{% /notice %}}


Update your vhost configuration to add the following:

[source,xml]
----
<VirtualHost *:80>

    DocumentRoot /<path-to-suite>/public
    <Directory /<path-to-suite>/public>
        AllowOverride All
        Order Allow,Deny
        Allow from All
    </Directory>

</VirtualHost>
----


=== Helpful resources:

* link:https://symfony.com/doc/current/setup/web_server_configuration.html#apache-with-mod-php-php-cgi[Symfony documentation on how to setup webserver (apache and others),window=_blank]
* link:https://www.digitalocean.com/community/tutorials/how-to-set-up-mod_rewrite[DigitalOcean - Tutorial on how to setup mod_write (apache),window=_blank]
** Note from the above you would only need:
*** Section 1—How to Activate Mod_Rewrites
*** How to permit changes in the .htaccess file:

== 5. Configure php error_reporting

Please make sure that notices aren't considered on `error_handling`. For that you can update the error handling entry in `php.ini`

[source,ini]
----
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE & ~E_WARNING
----


=== Helpful Resources

Please check the `Helpful Resources` section from link:#_2_install_required_software[Install required software] for instructions on where to find `php.ini`


== 6. (optional) Performance

For more information regarding performance optimization see the link:../performance/[Performance configuration guide]

'''

== 2. Downloading and Setting up SuiteCRM

=== 2.1 Checking Compatibility Matrix


[[smaller-table-spacing-10]]
[cols="1s,2" ]
|========

2+^h| Platform

| Linux, Unix, Mac OS | Any version supporting PHP

| PHP | 8.1, 8.2, 8.3

2+^h| Web Server

| Apache | 2.4

2+^h| Database

| MariaDB | 10.5, 10.6, 10.11

| MySQL |5.7, 8.0

2+^h| Browsers

| Chrome |109+

| Firefox |109+

| IE | 11 (compatibility mode not supported)

| Edge |109+

| Safari |16+

2+^h| Additional requirements for front-end Development (not required for production)

| Angular CLI | ^18
| Node.js | ^20.11.1
| yarn | ^4.5.0


=== 2.2 Downloading the latest SuiteCRM files

# DOWNLOAD LINK
https://suitecrm.com/download/165/suite88/565090/suitecrm-8-8-0.zip

=== 2.3 Copy the files to your webserver root

After you download the package

. Unzip the pre-build installable package.
. Copy the the files to your web server web root.

For `apache` webserver the web root is usually under `/var/www` or `/var/www/html`

{{% notice note %}}
Please consider the `DocumentRoot` you have set on your vhost (if using apache). See link:../webserver-setup-guide#_4_configuring_url_re_writes[Web Server Setup guide - 4. Configuring URL re-writes]
{{% /notice %}}

{{% notice note %}}
Adding the files to the web root is the most typical install method, but you can have different setups, like subdomains and others.
{{% /notice %}}

=== 2.4 Set permissions

Set the required permissions

If you are using the terminal you can do this by running:

[source,bash]
----
find . -type d -not -perm 2755 -exec chmod 2755 {} \;
find . -type f -not -perm 0644 -exec chmod 0644 {} \;
find . ! -user www-data -exec chown www-data:www-data {} \;
chmod +x bin/console
----

Please have in mind that:

* The user and group name (in the above example `www-data`) needs to be replaced by the actual system user and group that your webserver runs under. This varies depending on your
operating system. Common web server users are as follows:
** `www-data` (Ubuntu Linux/Apache)
** `apache` (Linux/Apache)

* If the group name differs from the username apache is running with, you may need `0664` instead of `0644`, and `2775` instead of `2755`

=== 2.5 Creating the database

Depending on your setup, you maybe required to create the database before you go through the install process.

The install process will then create the needed tables.

'''

== 3. Running the installer

From SuiteCRM version 8 and above you have two ways to run installer.

* link:../running-the-ui-installer/[Option 1: Installing using the installation page]
* link:../running-the-cli-installer/[Option 2: Installing using the cli]


---
title: "Running the CLI installer"
weight: 22
---

:imagesdir: /images/en/8.x/admin/install-guide

{{% notice info %}}
The following documentation is for SuiteCRM Version 8+; to see documentation for Version 7, click link:../../../../developer/introduction[here].
{{% /notice %}}

== 1. Intro

This page explains how to use the cli installer for SuiteCRM.

{{% notice note %}}
Before going through the steps on this page, please go through the link:../downloading-installing/[Downloading & Installing] guide.
{{% /notice %}}

== 2. Installing using the cli


=== 2.1 Install the system

* Run command:
. Option 1 - Run `./bin/console suitecrm:app:install` without any options, the command will ask you for the required options
. Option 2 - Run `./bin/console suitecrm:app:install` in one line by passing the required options the. See the section below for more detail.


[source,bash]
----
./bin/console suitecrm:app:install -u "admin_username" -p "admin_password" -U "db_user" -P "db_password" -H "db_host" -N "db_name" -S "site_url" -d "demo_data"
----

[source,bash]
----
#Example
./bin/console suitecrm:app:install -u "admin" -p "pass" -U "root" -P "dbpass" -H "mariadb" -N "suitecrm" -S "https://yourcrm.com/" -d "yes"
----

*Further Info*

To get more information on the supported arguments you can run:  `./bin/console suitecrm:app:install --help`. Which should show a list similar to the following:

image:suite-cli-install-options.png[suite-cli-install-options.png]


The following sub-sections provide a brief explanation of each parameter you can set

==== 2.1.1 site_url

In the above parameter you should set the url where your SuiteCRM instance is located. A few example:

* `https://example-domain.com`
* `https://localhost`
* `https://crm.example-domain.com`

**Tip: ** you can simply copy the url from you browser's address bar

==== 2.1.2 db_user

In the above parameter you should set the user name for accessing your database.

{{% notice note %}}
Ensure that the Database User you specify has the permissions to create and write to the SuiteCRM database.
{{% /notice %}}

==== 2.1.3 db_password

In the above parameter you should set the password for accessing your database.

==== 2.1.4 db_host

In the above parameter you should set the host of your database.

{{% notice note %}}
in some systems when using `localhost` doctrine will try to use socket connection. However, socket connection is not supported at the moment, so in such cases, its maybe best to try with the ip, e.g. `127.0.0.1`
{{% /notice %}}

==== 2.1.5 db_name

In the above parameter you should set the name you want for the databases that will be created on your host during the install process, e.g. `suite` or `suitecrm` or another valid db name.

==== 2.1.6 db_port

In the above parameter is set to the default port user in `mysql` and `mariadb` database engines. You should only change it in case your database host is using a different port.

==== 2.1.7 demo_data

In the above parameter you can set if, during the install process, you want to pre-populate your database with demo data.

Possible values: 'yes' , 'no'.

==== 2.1.8 admin_username

In the above parameter you can set the username for your SuiteCRM instance's administrator user, e.g. `admin` or any other username you want to give.

==== 2.1.9 admin_password

In the above parameter you can set the password for your SuiteCRM instance's administrator user.

==== 2.1.10 sys_check_option

Ignoring install warnings

Before running the install process, SuiteCRM is going to check for some system requirements, like `max upload file size` or `memory limit`. Some of these checks are optional, meaning that you can install the system without those.
In case you want to proceed with the installation even if there are warnings you can check the `Ignore System Check Warnings` checkbox

Possible values: 'true' (for ignoring) , 'false' (for *not* ignoring).

=== 2.2 Re-set permissions

After allowing time for the installation to complete, again set permissions.

If you are using the terminal you can do this by running:

[source,bash]
----
find . -type d -not -perm 2755 -exec chmod 2755 {} \;
find . -type f -not -perm 0644 -exec chmod 0644 {} \;
find . ! -user www-data -exec chown www-data:www-data {} \;
chmod +x bin/console
----

Please have in mind that:

* The user and group name (in the above example `www-data`) needs to be replaced by the actual system user and group that your webserver runs under. This varies depending on your
operating system. Common web server users are as follows:
** `www-data` (Ubuntu Linux/Apache)
** `apache` (Linux/Apache)

* If the group name differs from the username apache is running with, you may need `0664` instead of `0644`, and `2775` instead of `2755`

=== 2.3 Double-checking configurations

Please double-check that the following configurations are correct

*1* - Legacy config in `public/legacy/config`

* `site_url`:
** if you *do not* have your vhost pointing to the `public` dir within your SuiteCRM 8 root folder, you should append `/public` to your current host
*** e.g. if your address is something like `https://your-host/crm/public`,

*2* - `.htaccess` in `public/legacy/.htaccess

* `RewriteBase`
** If you have your vhost pointing to `public` dir within the SuiteCRM 8 root folder. Then the correct value is `RewriteBase /legacy`
** Otherwise, you should prepend the path until the `public` folder.
*** e.g. if your address is something like `https://your-host/crm/public`, then the correct value is `RewriteBase /crm/public/legacy`


=== 2.4  Access the app

You should now be able to access the instance at the `https://<your-suite-crm-instance-path>`



---
title: "Extension Structure"
weight: 20
---

:imagesdir: /images/en/8.x/developer/extensions/front-end/fe-extensions-setup

{{% notice info %}}
The following documentation is for SuiteCRM Version 8+; to see documentation for Version 7, click link:../../../../developer/introduction[here].
{{% /notice %}}


{{% notice note %}}
The following documentation assumes that you have a good understanding of the angular framework
{{% /notice %}}


== 1. Intro

The following guide provides an explanation of the structure of frontend extensions using the `defaultExt` extension, that comes with SuiteCRM since version 8.4.0, as an example / guideline.

Starting with version 8.4.0, SuiteCRM comes with a pre-configured frontend extension that is ready to be used for customizations.

Apart from being a starting point to start coding, it provides a base structure for you to use on your customisations.

The following sections will try to provide some info on how the defaultExt extension is structured and how to use it.

== 2. Extension Contents

An extension can include both backend and frontend customizations.

Each extension is a separate folder within the `extensions` folder.

All the contents of the extension are located under its folder. Thus, it is possible to remove an extension just by deleting the folder.

As mentioned earlier we will be using the `defaultExt` extension as an example, thus the folder is `extensions/defaultExt`.

== 3. Extension Structure

Under the extension the folder, in this case `extensions/defaultExt`, you can have 5 folder:

* app
** Contains the frontend code
* backend
** Contains the backend code
* modules
** Contains the module specific backend code and configuration
* config
** Contains the SuiteCRM 8 side configuration (not the SuiteCRM 7 side configuration)
* public
** Automatically generated by the frontend build command
** Contains the built version of the frontend extension
** When the cache is cleared, its contents are automatically copied to `public/extensions/defaultExt`

The above follows a similar structure as the one used in SuiteCRM core:

* configs
* core/app
* core/backend
* core/modules

=== 3.1 App Folder

The defaultExt extension comes with a pre-setup structure for frontend extensions. In essence, the app folder is a micro angular app with a special webpack config that uses the ModuleFederation plugin.

Your custom code should go under the `extensions/defaultExt/app/src` folder.

==== 3.1.1 Structure
To give developers an example on how to structure their apps, the defaultExt extension already includes the following folder as placeholders:

* components
* containers
* fields
* services
* views

The above are the main building blocks of the frontend code. When adding a new item within these you should try to keep the same structure that core uses. This will provide a pattern that makes it easier to navigate through the code.

Please note that this structure is not mandatory, it is a guideline and recommended.

==== 3.1.2 Extension Module

The `ExtensionModule` located in `extensions/defaultExt/app/src/extension.module.ts` is the entrypoint for all front end extension code.
In order for your custom code to be picked up it needs to be registered in the `ExtensionModule`, or some other file that is then used in the `ExtensionModule`

On some of the link:../frontend/examples/[frontend extension example guides] you can find examples of how to register your code for those extensions, so that it gets picked up.

=== 3.2 Backend and Modules Folders

The `backend` and `modules` folders are meant to contain backend code. They are autowired in Symfony, so they will automatically be picked up and classes can be used through dependency injection.

Ideally the files and folders added to `backend` should follow the same structure used on the `core/backend`.

The `modules` folder should have a folder for each module you want to extend. Within the module folder you can follow the same structure used in `core/backend`.

=== 3.3 Config Folder

The `config` folder is where you should place your extensions / overrides to the configuration.

== 4 Angular Setup

=== 4.1 angular.json
The `angular.json` file already contains the configuration needed to build the `defaultExt` extension. You can find the configurations under:

[source,json]
----
{
  ...

  "projects": {
    ...
    "defaultExt": {
      ...
    },

  ...
}
----

=== 4.2 package.json

The `package.json` contains 2 build commands that you can use:

==== 4.2.1 Development build

The following line in the `package.json` defines the dev build command

[source,json]
----
    "build-dev:defaultExt": "ng build defaultExt --configuration dev",
----

This command will build the defaultExt extension in a non-production mode.

Plus it will generate the files directly to the `public/extensions/defaultExt` folder, which allows to also use the `--watch` option.

Thus when developing, it is best to run:

[source,bash]
----
yarn run build-dev:defaultExt --watch
----

The command will stay on "watch" for changes to the files in the extension:

* It will automatically re-rebuild
* The re-build process is significantly faster than a full new build.
* After the auto re-build you just need to refresh your browser to get the changes
** Please use the `Empty Cache and Hard Reload" Option (or similar) from your browser to reload the page, to make sure you don't get any cached code

==== 4.2.2 Production Build

The following line in the `package.json` defines the production build command

[source,json]
----
    "build:defaultExt": "ng build defaultExt --configuration production",
----

This command will build the defaultExt extension in a production mode.

It will also generate the extension to the "final" location within the package: `extensions/defaultExt/public`. This is the location for the production extension code.

When the cache is cleared, using a `php bin/console cache:clear` or by deleting the cache, the code from `extensions/defaultExt/public` will be copied to `public/extensions/defaultExt`.

The reason to have two places for the code is:

* `extensions/defaultExt/public`
** Is the place to keep the built front end code.
** When the extension is installed in a new instance all the code comes with it, just by copying the `extensions/defaultExt` folder
** It also makes it easier to remove / disable an extension

* `public/extensions/defaultExt`
** Is a web accessible folder
** Since `extensions/defaultExt/public` is not a publicly accessible folder, the front end code needs to be copied over to a location that is web accessible.
** It is not the main source for the code, on every cache clear it will be deleted and the contents from `extensions/defaultExt/public` will be copied again

Therefore, after you've written and tested your extension using the dev command, you should run the following to build a "package-ready" and production version of your extension:

[source,bash]
----
yarn run build:defaultExt
----


---
title: "Introduction to the Process Api"
weight: 10
---

:imagesdir: /images/en/8.x/developer/extensions/backed-end/process-api/


== 1. Introduction

With SuiteCRM 8 and the new graphql api, there was the need to have a standard way to handle requests to the backend that are not strictly for retrieving or changing a module record fields/attributes.

This new mechanism is called `Process Api` and it is used for all kinds of actions that need to call the backend. Some examples:

* Delete
* Mass Update
* Print PDF
* Export
* Recover Password
* Backend Field Value Calculation
* ...

As you know, action requests many times do not fit in the usual get / update api for a record. Many times they even affect more than one record, need to send specific data, or other kinds of variations.

With the Process Api we've tried to provide a standard way to handle these scenarios, by adding support for:

* Authentication checking
* ACLs checking
* Data validation
* Process execution

== 2. Auto-registering of process handlers

All processes have a unique key and are registered in the `ProcessHandlerRegistry` by that unique key.

The unique key in each process is defined in the `getProcessType()` method.

All the process handlers are auto-registered they just need to implement the `ProcessHandlerInterface` and they should be picked up.

This auto-registering makes use of symfony's auto-wiring and autoconfiguration. The next subsections are going to explain the way this is setup.


=== 2.1 ProcessHandlerInterface auto-configuration

The file that contains the bulk of the symfony's configurations is `config/core_services.yaml`.

Within it, there is an autoconfiguration to tag all services that implement  the `App\Process\Service\ProcessHandlerInterface` with the `app.process.handler` tag.


[source,yaml]
----
services:
  # default configuration for services in *this* file
  _defaults:
    autowire: true      # Automatically injects dependencies in your services.
    autoconfigure: true # Automatically registers your services as commands, event subscribers, etc.
    public: false       # Allows optimizing the container by removing unused services.
    bind:

       ...

  _instanceof:
    App\Process\Service\ProcessHandlerInterface:
      tags: [ 'app.process.handler' ]

----

=== 2.1 Auto-wiring into the ProcessHandlerRegistry

Then using the configuration for the ProcessHandlerRegistry in the container, all services that have been tagged with the `app.process.handler` tag are injected in to the ProcessHandlerRegistry as the first argument of the constructor.

[source,yaml]
----
services:
  # default configuration for services in *this* file
  _defaults:
    autowire: true      # Automatically injects dependencies in your services.
    autoconfigure: true # Automatically registers your services as commands, event subscribers, etc.
    public: false       # Allows optimizing the container by removing unused services.

  ...

  App\Process\Service\ProcessHandlerRegistry:
    # inject all services tagged with app.process.handler as first argument
    # and use the value of the 'getProcessType' method to index the services
    arguments:
      - !tagged { tag: 'app.process.handler' }

----

Together with auto-loading and auto-wiring, we are able to tag and inject all classes that implement the `ProcessHandlerInterface` and are in a folder recognized by symfony.

== 3. Process Request GraphQL API

When an action is triggered, the angular front-end submits a process request through the graphql `createProcess` entity mutation.

[source]
----
type Process implements Node {
  id: ID!
  _id: String
  type: String
  status: String
  messages: Iterable
  async: Boolean
  options: Iterable
  data: Iterable
}
----

The graphql mutation is as follows:

[source]
----
mutation createProcess($input: createProcessInput!) {
  createProcess(input: $input) {
    process {
      _id
      status
      async
      type
      messages
      data
      __typename
    }
    clientMutationId
    __typename
  }
}
----

The following is an example of the inputs sent on the above request. This example is for the print-pdf action in Contacts:

[source,json]
----
{
    "input": {
        "type": "record-print-as-pdf",
        "options": {
            "action": "record-print-as-pdf",
            "module": "contacts",
            "id": "e4941b73-1c01-9016-3cdf-64181e7c4db4",
            "params": {
                "selectModal": {
                    "module": "AOS_PDF_Templates"
                },
                "modalRecord": {
                    "id": "7d1fd5f6-82a6-9f20-6e4f-643d64ed7be2",
                    "module": "pdf-templates",
                    "type": "AOS_PDF_Templates",
                    "attributes": {
                        "module_name": "AOS_PDF_Templates",
                        "object_name": "AOS_PDF_Templates",
                        "id": "7d1fd5f6-82a6-9f20-6e4f-643d64ed7be2",
                        "name": "test",
                        "date_entered": "2023-04-17 15:23:12",
                        "date_modified": "2023-04-17 15:23:12",
                        "modified_user_id": "1",
                        "modified_by_name": {
                            "user_name": "admin",
                            "id": "1"
                        },
                        "created_by": "1",
                        "created_by_name": {
                            "user_name": "admin",
                            "id": "1"
                        },
                        "description": "...",
                        "deleted": "",
                        "assigned_user_id": "1",
                        "assigned_user_name": {
                            "user_name": "admin",
                            "id": "1"
                        },
                        "active": "true",
                        "type": "Accounts",
                        "sample": "",
                        "insert_fields": "",
                        "pdfheader": "",
                        "pdffooter": "",
                        "margin_left": "15",
                        "margin_right": "15",
                        "margin_top": "16",
                        "margin_bottom": "16",
                        "margin_header": "9",
                        "margin_footer": "9",
                        "page_size": "A4",
                        "orientation": "Portrait"
                    },
                    "acls": [
                        "list",
                        "edit",
                        "view",
                        "delete",
                        "export",
                        "import"
                    ]
                }
            }
        }
    }
}
----

Here is another example for the `delete` action:

[source,json]
----
{
    "input": {
        "type": "record-delete",
        "options": {
            "action": "record-delete",
            "module": "contacts",
            "id": "e4941b73-1c01-9016-3cdf-64181e7c4db4",
            "params": {
                "displayConfirmation": true,
                "confirmationLabel": "NTC_DELETE_CONFIRMATION"
            }
        }
    }
}
----

From the two examples above we can identify that there are some properties that are sent on most requests:

**type**
The process type, that is going to be used to trigger the corresponding handler on the backend.

**options.module**
The `module` within the `options` is not mandatory, but most process requests send it.

**options.action**
The `actions` within the `options` is not mandatory, but most process requests send it.

**options.params**
Sent on almost all request, but each request will contain inputs specific to the process being called.

== 3. Process Request Backend Handling

There is a single entrypoint for all the process requests named ProcessDataPersister, which can be found on `core/backend/Process/DataPersister/ProcessDataPersister.php`

For all requests it will (as depicted on the following code snippet taken from core):

. Get the matching `ProcessHandler` from the `ProcessHandlerRegistry`
. Check if the required authentication level. I.e. if it requires a logged-in user and if the current user is an authenticated user
. Validate the request data
. Check SuiteCRM acls for the process.
. Do the needed configurations to the process
. Run
. Return the response


[source,php]
----
    public function persist($process, array $context = []): Process
    {
        $processHandler = $this->registry->get($process->getType());

        $this->checkAuthentication($processHandler);

        $processHandler->validate($process);

        $hasAccess = $this->checkACLAccess($processHandler, $process);

        $processHandler->configure($process);

        if (!$hasAccess) {
            $process->setMessages(['LBL_ACCESS_DENIED']);
            $process->setStatus('error');

            return $process;
        }

        if ($process->getAsync() === true) {
            // Store process for background processing
            // Not supported yet
        } else {
            $processHandler->run($process);
        }

        return $process;
    }
----

== 4. Adding a Process Handler

With this information you now have base knowledge about the process api, which should allow you to understand the base flow of a request.

The next step is to understand how to add a new process handler. Check the link:../process-handler[Adding a Process Handler] guide.


---
title: "Adding a Process Handler"
weight: 20
---

:imagesdir: /images/en/8.x/developer/extensions/backed-end/process-api/



== 1. Introduction

{{% notice info %}}
Before reading this page, please make sure to read the link:../process-api[Process Api] guide.
{{% /notice %}}

The link:../process-api[Process Api] guide describes the reason and purpose of having Process Handlers.

This page will try to provide a step-by-step guide on how to add a Process Handler.

As an implementation example we will use a ProcessHandler used for the `updateValueBackend` logic, as described on the link:../../../frontend/logic/field-logic/fe-extensions-update-value-backend[Update Field Value Based on a backend calculation] guide.


== 2. Adding a Backend Process Handler


{{% notice note %}}
When making these changes be sure to make them within an extension on the 'extensions' directory, e.g.: 'extensions/<my-extension>/...'
{{% /notice %}}

In the following example we are going to use the existing `extensions/defaultExt` to add our custom code.


=== 2.1 Steps to add a new process handler to extensions

{{% notice info %}}
As a best practice extension backend code should be added to `extensions/<your-extension>/backend/` or `extensions/<your-extension>/modules/`. For `extensions/<your-extension>/backend/` the subfolder should follow the same structure as used in `core/backend`
{{% /notice %}}


. Create the folder `extensions/defaultExt/modules/Cases/Service/Fields`
.. This is a best practice not a hard requirement
.. As long as you add under the `extensions/<your-ext>/backend` or `extensions/<your-ext>/modules` it should work.
. Within that folder create the `CaseCalculatePriority.php`, i.e. `extensions/defaultExt/modules/Cases/Service/Fields/CaseCalculatePriority.php`
.. If you are not using the recommended path, make sure that the `namespace` follows the one you are using
.. On our example the namespace is `namespace App\Extension\defaultExt\modules\Cases\Service\Fields;`
. On `CaseCalculatePriority.php`, add the code on the snippet on link:./#_2_2_process_handler_implementation[2.2 Process handler implementation] section
. Run `php bin/console cache:clear` or delete the contents of the cache folder under the root of the project
. Re-set the correct file permissions if you need to (This will depend on your setup and the user you are using to make changes)



=== 2.2 Process handler implementation

To add a `ProcessHandler` the class needs to implement the `ProcessHandlerInterface`. Plus for it to be matched with a request, it needs the following:

- Set the `ProcessType` to be the same as the value that was defined on the metadata (or other), in this example it is `case-calculate-priority`

The following snippet has sample implementation of the process handler:

[source,php]
----
<?php

namespace App\Extension\defaultExt\modules\Cases\Service\Fields;

use ApiPlatform\Core\Exception\InvalidArgumentException;
use App\Process\Entity\Process;
use App\Process\Service\ProcessHandlerInterface;

class CaseCalculatePriority implements ProcessHandlerInterface
{
    protected const MSG_OPTIONS_NOT_FOUND = 'Process options are not defined';
    public const PROCESS_TYPE = 'case-calculate-priority';

    /**
     * CaseCalculatePriority constructor.
     */
    public function __construct()
    {
    }

    /**
     * @inheritDoc
     */
    public function getProcessType(): string
    {
        return self::PROCESS_TYPE;
    }

    /**
     * @inheritDoc
     */
    public function requiredAuthRole(): string
    {
        return 'ROLE_USER';
    }

    /**
     * @inheritDoc
     */
    public function getRequiredACLs(Process $process): array
    {
        $options = $process->getOptions();
        $module = $options['module'] ?? '';
        $id = $options['id'] ?? '';

        $editACLCheck =  [
            'action' => 'edit',
        ];

        if ($id !== '') {
            $editACLCheck['record'] = $id;
        }

        return [
            $module => [
                $editACLCheck
            ],
        ];
    }

    /**
     * @inheritDoc
     */
    public function configure(Process $process): void
    {
        //This process is synchronous
        //We aren't going to store a record on db
        //thus we will use process type as the id
        $process->setId(self::PROCESS_TYPE);
        $process->setAsync(false);
    }

    /**
     * @inheritDoc
     */
    public function validate(Process $process): void
    {

        $options = $process->getOptions();
        $type = $options['record']['attributes']['type'] ?? '';
        if (empty($type)) {
            throw new InvalidArgumentException(self::MSG_OPTIONS_NOT_FOUND);
        }
    }

    /**
     * @inheritDoc
     */
    public function run(Process $process)
    {
        $options = $process->getOptions();

        $type = $options['record']['attributes']['type'] ?? '';

        if ($type !== 'User') {
            $priority = $options['record']['attributes']['priority'] ?? '';

            $responseData = [
                'value' => $priority
            ];

            $process->setStatus('success');
            $process->setMessages([]);
            $process->setData($responseData);

            return;
        }

        $name = $options['record']['attributes']['name'] ?? '';

        $value = 'P3';
        if (strpos(strtolower($name), 'warning') !== false) {
            $value = 'P2';
        }

        if (strpos(strtolower($name), 'error') !== false) {
            $value = 'P1';
        }

        $responseData = [
            'value' => $value
        ];

        $process->setStatus('success');
        $process->setMessages([]);
        $process->setData($responseData);
    }
}
----

==== 2.2.1 Process Handler implementation


===== 2.2.1.1 getProcessType()

This method should return the identifier of the process the handler implements. The same that is defined on the metadata logic `key` entry. In our example: `case-calculate-priority`

===== 2.2.1.2 requiredAuthRole()

This method defines if the auth role that is required to have access to the process.

- `'ROLE_USER'` means that the user needs to be logged in to have access to this process.
- `'ROLE_ADMIN'` means that the user needs to be logged in as an admin user to have access to this process.
- `''` means that a non-authenticated user can access the process.

===== 2.2.1.3 getRequiredACLs()

This method defines the SuiteCRM ACLs that are required to have access to the process.

====== Structure

The `getRequiredACLs` returns an array where we can define the modules, actions and record(s) that should be checked for ACLs.
This supports a very wide combination of checks.

The structure of the response array is the following:

**Module level**

We can define multiple modules to checked

[source,php]
----
        return [
            '<module-a>' => [],
            '<module-b>' => [],
        ];
----

**Action Level**

We can also define multiple actions to be checked per module

[source,php]
----
        return [
            '<module-a>' => [
                [
                    'action' => 'view',
                ],
                [
                    'action' => 'edit',
                    'record' => 'e1bd1...' // id to be checked
                ]
                [
                    'action' => 'delete',
                    'ids' => [ 'e1bd1...', ...] // array if ids
                ],
            ],
        ];
----

**Module Action Level Check**

We can check if the given module has access to a given action.

[source,php]
----
        return [
            '<module-a>' => [
                [
                    'action' => 'view',
                ],
            ],
        ];
----

**Module Record Action Level Check**

We can check if we have access to a record and to do a specific action on that record.

[source,php]
----
        return [
            '<module-a>' => [
                [
                    'action' => 'edit',
                    'record' => 'e1bd1...' // id to be checked
                ]
            ],
        ];
----

**Module Multi-Record Action Level Check**

We can check if we have access to several records and to do a specific action on those records.

{{% notice info %}}
This should be used carefully as this can have a big impact on performance. Each record ACLs is going to be checked individually.
{{% /notice %}}

[source,php]
----
        return [
            '<module-a>' => [
                [
                    'action' => 'delete',
                    'ids' => [ 'e1bd1...', ...] // array if ids
                ],
            ],
        ];
----


====== Examples

The following examples are taken from the existing core code.

**Skip ACL Check**

[source,php]
----
    public function getRequiredACLs(Process $process): array
    {
        return [];
    }
----

**Check Record Level ACLs For Single Record**

[source,php]
----
    /**
     * @inheritDoc
     */
    public function getRequiredACLs(Process $process): array
    {
        ['recentlyViewed' => $recentlyViewed] = $process->getOptions();
        $itemId = $recentlyViewed['attributes']['item_id'] ?? '';
        $itemModule = $recentlyViewed['attributes']['module_name'] ?? '';

        return [
            $itemModule => [
                [
                    'action' => 'view',
                    'record' => $itemId
                ]
            ]
        ];
    }
----

**Check Record Level ACLs For Record List**

[source,php]
----
    public function getRequiredACLs(Process $process): array
    {
        $options = $process->getOptions();
        $module = $options['module'] ?? '';
        $ids = $options['ids'] ?? [];

        return [
            $module => [
                [
                    'action' => 'export',
                    'ids' => $ids
                ]
            ]
        ];
    }
----

**Multiple ACL Checks Per Module**
[source,php]
----
    /**
     * @inheritDoc
     */
    public function getRequiredACLs(Process $process): array
    {
        $options = $process->getOptions();
        $module = $options['module'] ?? '';
        $ids = $options['ids'] ?? [];


        return [
            $module => [
                [
                    'action' => 'view'
                ],
                [
                    'action' => 'export',
                    'ids' => $ids
                ]
            ]
        ];
    }
----

**Multiple Module ACL Checks**

[source,php]
----
    /**
     * @inheritDoc
     */
    public function getRequiredACLs(Process $process): array
    {
        $options = $process->getOptions();
        $baseModule = $options['module'] ?? '';
        $baseIds = $options['ids'] ?? [];
        $modalRecord = $options['modalRecord'] ?? [];
        $modalModule = $modalRecord['module'] ?? '';
        $modalRecordId = $modalRecord['id'] ?? '';

        return [
            $baseModule => [
                [
                    'action' => 'view',
                    'ids' => $baseIds
                ]
            ],
            $modalModule => [
                [
                    'action' => 'view',
                    'record' => $modalRecordId,
                ]
            ],
        ];
    }
----




===== 2.2.1.4 validate()

This method is where we should add the code to validate the process inputs.

If the inputs aren't valid it should throw a `InvalidArgumentException`

===== 2.2.1.4 run()

This method is where we add the code to run the logic that our ProcessHandler is supposed to do.

This method **does not** return anything. Instead, it should update the `$process` argument that is passed by reference.


====== Setting response result and message

The following are some examples of how to set the feedback for the response.

**Success with no message**
[source,php]
----
        $process->setStatus('success');
        $process->setMessages([]);
----

**Success with no message**
[source,php]
----
        $process->setStatus('success');
        $process->setMessages(['LBL_BULK_ACTION_DELETE_SUCCESS']);
----


**Error with an error message**
[source,php]
----
            $process->setStatus('error');
            $process->setMessages(['LBL_ACTION_ERROR']);
----

====== Setting response data
The following are some examples of how to set the data on the respose.

The format on the response will vary depending on the type of ProcessHandler.


**Record Action, Line Action, Bulk Action process handlers**
[source,php]
----
        $responseData = [
            'handler' => 'redirect',
            'params' => [
                'route' => $options['module'] . '/duplicate/' . $options['id'],
                'queryParams' => [
                    'isDuplicate' => true,
                ]
            ]
        ];

        $process->setStatus('success');
        $process->setMessages([]);
        $process->setData($responseData);
----

Another example from `UpdateFavorite` process handler


[source,php]
----
            $process->setData([
                'favorite' => $savedFavorite
            ]);
----


---
title: "Backend-end Developer Install Guide"
weight: 10
---

:imagesdir: /images/en/8.x/developer/extensions/front-end/fe-architecture-intro

{{% notice info %}}
The following documentation is for SuiteCRM Version 8+; to see documentation for Version 7, click link:../../../../developer/introduction[here].
{{% /notice %}}

== 1. Before you start

This guide is meant for developers that want to build SuiteCRM from the source code, without using the provided pre-built package.

In order to do customizations it is not required to build from the source code. We recommend that you try provided packages first, please check:

* the link:../../../admin/releases/[Release page] for more info on where to download the packages
* the link:../../../admin/installation-guide/downloading-installing/[Downloading & Installing] for more info on how to install using a package

If you don't want to use the provided packages please continue through the following steps

== 2. Setup Web Server

The first step to take is to setup the webserver.

Please go through the link:../../../admin/installation-guide/webserver-setup-guide/[Webserver Setup Guide].

== 2. Downloading and Setting up SuiteCRM

=== 2.1 Downloading the latest SuiteCRM files

Assuming you want to install a development environment from the source files, the next step is to actually retrieve the source code for the version you want to use

You can download a zip or directly checkout using git from the link:https://github.com/salesagility/SuiteCRM-Core[SuiteCRM-Core] repo on github

=== 2.2 Copy the files to your webserver root

After checking out the files copy them to your web server web root.

For `apache` webserver the web root is usually under `/var/www` or `/var/www/html`

{{% notice note %}}
Please consider the `DocumentRoot` you have set on your vhost (if using apache). See link:../../../admin/installation-guide/webserver-setup-guide#_4_configuring_url_re_writes[Web Server Setup guide - 4. Configuring URL re-writes]
{{% /notice %}}

{{% notice note %}}
Adding the files to the web root is the most typical install method, but you can have different setups, like subdomains and others.
{{% /notice %}}

=== 2.3 Set permissions

Set the required permissions

If you are using the terminal you can do this by running:

[source,bash]
----
find . -type d -not -perm 2755 -exec chmod 2755 {} \;
find . -type f -not -perm 0644 -exec chmod 0644 {} \;
find . ! -user www-data -exec chown www-data:www-data {} \;
chmod +x bin/console
----

Please have in mind that:

* The user and group name (in the above example `www-data`) needs to be replaced by the actual system user and group that your webserver runs under. This varies depending on your
operating system. Common web server users are as follows:
** `www-data` (Ubuntu Linux/Apache)
** `apache` (Linux/Apache)

* If the group name differs from the username apache is running with, you may need `0664` instead of `0644`, and `2775` instead of `2755`

=== 2.4 (optional) Creating the database

Depending on your setup, you maybe required to create the database before you go through the install process.

The install process will then create the needed tables.

== 3. Install Front-End

Before you continue with this guide you need to first setup the frontend part of the app.

Please go through the link:../8.8.0-front-end-installation-guide[Front-end Developer install guide]

== 4. Install dependencies

{{% notice note %}}
You only need to do this step once. After the dependencies are installed you should only need to run it again after upgrading to a new SuiteCRM version
{{% /notice %}}


. Install  link:https://getcomposer.org/[Composer]
. Run `composer install` in the root directory of your SuiteCRM instance
. Run legacy theme compile in the root directory
- *NOTE:* the `./vendor/bin/pscss` is added as a composer dev dependency, so you need to run `composer install` *without* `--no-dev`
+
[source,bash]
----
./vendor/bin/pscss -s compressed ./public/legacy/themes/suite8/css/Dawn/style.scss > ./public/legacy/themes/suite8/css/Dawn/style.css
----

== 5. Set permissions

See link:#_2_3_set_permissions[Set permissions]

== 6. Running the installer

From SuiteCRM version 8 and above you have two ways to run installer.

* link:../../../admin/installation-guide/running-the-ui-installer/[Option 1: Installing using the installation page]
* link:../../../admin/installation-guide/running-the-cli-installer/[Option 2: Installing using the cli]



---
title: Introduction
weight: 10
---

SuiteCRM API version 8 exposes a set of resources, to be consumed by clients who wish to harness 
the powerful CRM functionality provided by SuiteCRM.

The API framework employs a Restful design to facilitate the http://jsonapi.org/format/1.0/[JSON API 1.0] 
standard messages over HTTPS. It includes meta objects to provide functionality which is not yet defined 
in the JSON API 1.0 standard. The SuiteCRM API is secured by the OAuth 2 Server provided in SuiteCRM.



---
title: Requirements
weight: 20
---

:imagesdir: /images/en/developer

In order to prevent man-in-the-middle attacks, the authorization server
MUST require the use of TLS with server authentication as defined by
https://tools.ietf.org/html/rfc2818[RFC2818] for any request sent to the
authorization and token endpoints. 

The client MUST validate the
authorization server's TLS certificate as defined by
https://tools.ietf.org/html/rfc6125[RFC6125] and in accordance with its
requirements for server identity authentication.

SuiteCRM uses key cryptography in order to encrypt and decrypt, as well
as verify the integrity of signatures.

Please ensure that you have the following:

* OpenSSL PHP Extension installed and configured
* The SuiteCRM instance must be configured to use HTTPS/SSL
* You need to have PHP version 5.5.9, or 7.0 and above

To be able to successfully connect to the endpoints, you need to complete the steps under section
link:../json-api/#_before_you_start_calling_endpoints[Before you start calling endpoints]
in addition to what is mentioned here.


---
title: JSON API
weight: 30
---

== Before you start calling endpoints

Please check the following below:

=== Composer

Install composer packages with

[source,shell]
composer install

=== Generate private and public.key for OAUTH2

SuiteCRM Api uses OAuth2 protocol, which needs public and private keys.

First, open a terminal and go to `{{suitecrm.root}}/Api/V8/OAuth2`

Generate a private key:
[source,shell]
openssl genrsa -out private.key 2048

Then a public key:
[source,shell]
openssl rsa -in private.key -pubout -out public.key

If you need more information about generating, https://oauth2.thephpleague.com/installation/[please visit this page].

The permission of the key files must be 600 or 660, so change it.
[source,shell]
sudo chmod 600 private.key public.key

Also, you have to be sure that the config files are owned by PHP.
[source,shell]
sudo chown www-data:www-data p*.key

=== OAUTH2 encryption key
OAuth2’s AuthorizationServer needs to set an encryption key for security reasons.
This key has been generated during the SuiteCRM installation and stored in the config.php under "oauth2_encryption_key".
If you would like to change its value you may generate a new one by running
[source,shell]
php -r 'echo base64_encode(random_bytes(32)), PHP_EOL;'

and then store the output in the config.php

Current releases all use the value directly from `config.php`

Older versions updated the file `/Api/Core/Config/Apiconfig.php` with the value from `config.php` when running a repair and rebuild.
If any issues arise and you are troubleshooting it may be worth taking a look there.

If you need more information about this issue, https://oauth2.thephpleague.com/v5-security-improvements/[please visit this page].

=== Verify if rewrite module is installed and activated
It is necessary to verify if '**mod_rewrite**' module of Apache server is enabled. Make sure to **enable** and activate it. This process depends on Operating System, installed versions of software etc. Please check this stackoverflow's answers https://stackoverflow.com/questions/7337724/how-to-check-whether-mod-rewrite-is-enable-on-server/10891317#10891317/[1], https://stackoverflow.com/questions/18310183/how-to-check-for-mod-rewrite-on-php-cgi/27589801#27589801/[2] to get directions how to enable the module.

Also, for the SuiteCRM location (root{/var/www} or subdir{/var/www/subdir}) one should change **AllowOverride** directive inside Directory directive from **None** to **All** to assure that rewrite rules of .htaccess work:
[source,apache]
<Directory /var/www/subdir>
	Options Indexes FollowSymLinks
	AllowOverride All
	Require all granted
</Directory>

== Authentication

SuiteCRM Api allows two kind of grant types:

* Client credential
* Password

.Token request parameters
|===
|Parameter |Description

|*Access Token URL*
|{{suitecrm.url}}/Api/access_token

|*Username*
|Only available for Password grants. Must be a valid SuiteCRM user name.

|*Password*
|Only available for Password grants. Password for the selected user.

|*Client ID*
|Client ID exists in OAuth2Clients module's ID. Must be a valid GUID.

|*Client Secret*
|Client secret is also in OAuth2Clients module as SHA256 generated value.

|*Scopes*
|Scopes haven't implemented yet
|===

== Available parameters

According to JsonApi specification, the available parameters are the following depending on the GET endpoint:

=== Fields

Fields can filter on attribute object. Allowed keys are valid bean properties.

Example:

[source,html]
{{suitecrm.url}}/Api/V8/module/Accounts/11a71596-83e7-624d-c792-5ab9006dd493?fields[Accounts]=name,account_type

Result:

[source,json]
{
    "data": {
        "type": "Account",
        "id": "11a71596-83e7-624d-c792-5ab9006dd493",
        "attributes": {
            "name": "White Cross Co",
            "account_type": "Customer"
        },
        "relationships": {
            "AOS_Contracts": {
                "links": {
                    "related": "/V8/module/Accounts/11a71596-83e7-624d-c792-5ab9006dd493/relationships/aos_contracts"
                }
            }
        }
    }
}

=== Page

Page can filter beans and set pagination. Allowed key are *number* and *size*.

* *page[number*] : number of the wanted page
* *page[size*] : size of the result

Example:

[source,php]
{{suitecrm.url}}/Api/V8/module/Accounts?fields[Account]=name,account_type&page[number]=3&page[size]=1

Result:

[source,json]
{
    "meta": {
        "total-pages": 54
    },
    "data": [
        {
            "type": "Account",
            "id": "e6e0af95-4772-5773-ae70-5ae70f931feb",
            "attributes": {
                "name": "",
                "account_type": ""
            },
            "relationships": {
                "AOS_Contracts": {
                    "links": {
                        "related": "/V8/module/Accounts/e6e0af95-4772-5773-ae70-5ae70f931feb/relationships/aos_contracts"
                    }
                }
            }
        }
    ],
    "links": {
        "first": "/V8/module/Accounts?fields[Account]=name,account_type&page[number]=1&page[size]=1",
        "prev": "/V8/module/Accounts?fields[Account]=name,account_type&page[number]=2&page[size]=1",
        "next": "/V8/module/Accounts?fields[Account]=name,account_type&page[number]=4&page[size]=1",
        "last": "/V8/module/Accounts?fields[Account]=name,account_type&page[number]=54&page[size]=1"
    }
}

=== Sort

Sort is only available when collections wanted to be fetched.
Sorting is set to ASC by default. If the property is prefixed with hyphen, the sort order changes to DESC.

**Important notice:** we only support single sorting right now!

Example:

[source,php]
{{suitecrm.url}}/Api/V8/module/Accounts?sort=-name

Result:

[source,json]
{
    "data": [
        {
            "type": "Account",
            "id": "e6e0af95-4772-5773-ae70-5ae70f931feb",
            "attributes": {
                "name": "White Cross Co",
                "account_type": "Customer"
            },
            "relationships": {
                "AOS_Contracts": {
                    "links": {
                        "related": "/V8/module/Accounts/1d125d2a-ac5a-3666-f771-5ab9008b606c/relationships/aos_contracts"
                    }
                }
            }
        },
        {
            "type": "Account",
            "id": "7831d361-2f3c-dee4-d36c-5ab900860cfb",
            "attributes": {
                "name": "Union Bank",
                "account_type": "Customer"
            },
            "relationships": {
                "AOS_Contracts": {
                    "links": {
                         "related": "/V8/module/Accounts/7831d361-2f3c-dee4-d36c-5ab900860cfb/relationships/aos_contracts"
                    }
                }
            }
        }
    ],
}

=== Filter

Our filter strategy is the following:

- filter[operator]=and
- filter[account_type][eq]=Customer

**Important notice:** we don't support multiple level sorting right now!

==== Supported operators

===== Comparison

[source,php]
EQ = '=';
NEQ = '<>';
GT = '>';
GTE = '>=';
LT = '<';
LTE = '<=';

===== Logical
[source,php]
'AND', 'OR'

Example:

[source,html]
{{suitecrm.url}}/Api/V8/module/Accounts?fields[Accounts]=name,account_type&filter[operator]=and&filter[account_type][eq]=Customer

Example:

[source,php]
{{suitecrm.url}}/Api/V8/module/Accounts?filter[account_type][eq]=Customer



Result:

[source,json]
----
----

== Endpoints

=== Logout

[source,php]
POST {{suiteCRM.url}}/Api/V8/logout

=== Modules

[source,php]
GET {{suiteCRM.url}}/Api/V8/meta/modules

=== Module Fields

[source,php]
GET {{suiteCRM.url}}/Api/V8/meta/fields/{moduleName}

=== Get a module by ID

[source,php]
GET {{suitecrm.url}}/Api/V8/module/{moduleName}/{id}

Available parameters: fields

Example:

[source,html]
Api/V8/module/Accounts/11a71596-83e7-624d-c792-5ab9006dd493?fields[Accounts]=name,account_type

=== Get collection of modules

[source,php]
GET {{suitecrm.url}}/Api/V8/module/{moduleName}

Available parameters: fields, page, sort, filter

Example:

[source,html]
Api/V8/module/Accounts?fields[Accounts]=name,account_type&page[size]=4&page[number]=4

=== Create a module record

[source,php]
POST {{suitecrm.url}}/Api/V8/module

Example body:

[source,json]
{
  "data": {
    "type": "Accounts",
    "attributes": {
      "name": "Test account"
    }
  }
}

=== Update a module record

[source,php]
PATCH {{suitecrm.url}}/Api/V8/module

Example body:

[source,json]
{
  "data": {
    "type": "Accounts",
    "id": "11a71596-83e7-624d-c792-5ab9006dd493",
    "attributes": {
      "name": "Updated name"
    }
  }
}

=== Delete a module record

[source,php]
DELETE {{suitecrm.url}}/Api/V8/module/{moduleName}/{id}

== Relationship Endpoints

=== Get relationship

[source,php]
GET {{suitecrm.url}}/Api/V8/module/{moduleName}/{id}/relationships/{linkFieldName}

Example:

[source,html]
Api/V8/module/Accounts/129a096c-5983-1d59-5ddf-5d95ec91c144/relationships/members

=== Create relationship

[source,shell]
POST {{suitecrm.url}}/Api/V8/module/{moduleName}/{id}/relationships/{linkFieldName}

body:

[source,json]
----
{
  "data": {
    "type": "{relatedModuleName}",
    "id": "{relatedBeanId}"
  }
}
----

=== Delete relationship

[source,html]
DELETE {{suitecrm.url}}/Api/V8/module/{moduleName}/{id}/relationships/{linkFieldName}/{relatedBeanId}

Example:

[source,html]
/Api/V8/module/Accounts/129a096c-5983-1d59-5ddf-5d95ec91c144/relationships/members/11a71596-83e7-624d-c792-5ab9006dd493




---
title: Available Grant Types
weight: 40
---
:imagesdir: /images/en/developer/


== Configure Authentication: Obtaining A Session

The SuiteCRM API requires that a client has an active session to consume
the API. Sessions are acquired by authenticating with the
http://oauth2.thephpleague.com/[OAuth 2 Server], using one of the
available grant types.

== Configure Grant Types
Before you can consume the API, you must first configure SuiteCRM to
grant access to a client. SuiteCRM 7.10 provides an administrative
panel, through which you can add clients and revoke tokens. To configure the grant types, select the admin panel, and then select OAuth2 Clients and Tokens:

image:Admin-OAuth2Clients-3.png[Configure SuiteCRM API]

== Available Grant Types

[width="50, cols="25,25",options="header",]
|=======================================
|SuiteCRM Version |Available Grant Types
|7.10.0 | Password Grant, Refresh Token Grant
|7.10.2 + | Password Grant, Client credentials Grant, Refresh Token Grant
|=======================================

image:Admin-OAuth2Clients-4.png[Create a new grant]

== Client Credentials Grant

A client credentials grant is the simplest of all of the grants types, this grant is used to authenticate a machine or service. Select new client credentials client:

image:Admin-OAuth2Clients-8.png[Create a new client credentials grant]

Begin configuring the grant:

image:Admin-OAuth2Clients-2.png[Create a new Client]

[cols="15,85",options="header"]
|=======================================================================
| Field| Description
|*Name* |This makes it easy to identify the client.
|*Secret* |Defines the *client_secret* which is posted to the server
during authentication.
|*Is Confidential* |A confidential client is an application that is
capable of keeping a client password confidential to the world.
|*Associated User* |Limits the client access to CRM, by associating the client with the security privileges of a user.
|=======================================================================


The 'secret' will be hashed when saved, and will not be accessible
later. The 'id' is created by SuiteCRM and will be visible once the
client is saved.

image:Admin-OAuth2Clients-5.png[View a Client Credentials Client]

== Authentication with Client Credentials

[source,php]
POST /Api/access_token

[[required-parameters]]
=== Required parameters

[width="40",cols="20,20",options="header",]
|======================================
|param |value
|grant_type |client_credentials
|client_id |*ExampleClientName*
|client_secret |*ExampleSecretPassword*
|======================================


.Example Request (PHP):
[source,php]
$ch = curl_init();
$header = array(
    'Content-type: application/vnd.api+json',
    'Accept: application/vnd.api+json',
 );
$postStr = json_encode(array(
    'grant_type' => 'client_credentials',
    'client_id' => '3D7f3fda97-d8e2-b9ad-eb89-5a2fe9b07650',
    'client_secret' => 'client_secret',
));
$url = 'https://path-to-instance/Api/access_token';
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
curl_setopt($ch, CURLOPT_POSTFIELDS, $postStr);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_HTTPHEADER, $header);
$output = curl_exec($ch);

.Example Response:
[source,php]
{
   "token_type":"Bearer",
   "expires_in":3600,
   "access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjdkOTEyODNhMjc1NDdkNDRlMzNmOTc5ZjVmMGRkYzQwNzg1ZGY5NGFhMWI5MDVlZGNmMzg3NWIxYjJkZDMzNDljZWEyNjZhMTQ2OTE5OWIzIn0.eyJhdWQiOiJzdWl0ZWNybV9jbGllbnQiLCJqdGkiOiI3ZDkxMjgzYTI3NTQ3ZDQ0ZTMzZjk3OWY1ZjBkZGM0MDc4NWRmOTRhYTFiOTA1ZWRjZjM4NzViMWIyZGQzMzQ5Y2VhMjY2YTE0NjkxOTliMyIsImlhdCI6MTUxODE5NTEwMiwibmJmIjoxNTE4MTk1MTAyLCJleHAiOjE1MTgxOTg3MDIsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.EVGuRisoMxSIZut3IWtgOYISw8lEFSZgCWYCwseLEfOuPJ8lRMYL4OZxhu9gxJoGF0nj3yc6SYDPxovrsoj8bMoX38h4krMMOHFQLoizU0k2wAceOjZG1tWKPhID7KPT4TwoCXbb7MqAsYtVPExH4li7gSphJ8wvcWbFdS5em89Ndtwqq3faFtIq6bv1R4t0x98HHuT7sweHUJU40K9WQjbAfIOk8f5Y6T2wassN2wMCBB8CC6eUxLi14n2D6khHvkYvtPbXLHpXSHZWvEhqhvjAeSR5MmMrAth9WDSWUx7alO-ppsZpi8U7-g9Be5p6MRatc25voyTI2iTYbx02FQ",
}


[cols="15,80"]
|=======================================================================
|*token_type* |the Bearer token value

|*expires_in* |an integer representing the TTL of the access token

|*access_token* |a https://tools.ietf.org/html/rfc7519[JWT] signed with
the authorization server’s private key. It is required that you include
this in the HTTP headers, each time you make a request to the API

|=======================================================================

You can store the bearer token in a database and use in your requests
like this:

.Example
[source,php]
$header = array(
   'Content-type: application/vnd.api+json',
   'Accept: application/vnd.api+json',
   'Authorization: Bearer ' . $your_saved_access_token
);

'''

== Password Grant

A password grant is used for allow users to log into SuiteCRM with a
username and a password. Select new password client:

image:Admin-OAuth2Clients-9.png[Create a Password Client]

Begin configuring grant:

image:Admin-OAuth2Clients-6.png[Create a new Client]

[cols="15,85", frame="none", grid="none"]
|=======================================================================
|*Name* |This makes it easy to identify the client.
|*Secret* |Defines the *client_secret* which is posted to the server
during authentication.
|*Is Confidential* |A confidential client is an application that is
capable of keeping a client password confidential to the world.
|=======================================================================


The 'secret' will be hashed when saved, and will not be accessible
later. The 'id' is created by SuiteCRM and will be visible once the
client is saved.

image:Admin-OAuth2Clients-7.png[View a password grant client]

=== Authentication with Password Grant

[source,php]
POST /Api/access_token

[[required-parameters-1]]
=== Required parameters

[width="40",cols="20,20",options="header",]
|======================================
|param |value
|grant_type |password
|client_id |*ExampleClientName*
|client_secret |*ExampleSecretPassword*
|username |*admin*
|password |*secret*
|======================================

Please change the values in bold to match your chosen authentication
details.

.Example Request (PHP):
[source,php]
$ch = curl_init();
$header = array(
    'Content-type: application/vnd.api+json',
    'Accept: application/vnd.api+json',
 );
$postStr = json_encode(array(
    'grant_type' => 'password',
    'client_id' => '3D7f3fda97-d8e2-b9ad-eb89-5a2fe9b07650',
    'client_secret' => 'client_secret',
    'username' => 'admin',
    'password' => 'admin',
));
$url = 'https://path-to-instance/Api/access_token';
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
curl_setopt($ch, CURLOPT_POSTFIELDS, $postStr);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_HTTPHEADER, $header);
$output = curl_exec($ch);

.Example Response:
[source,php]
{
   "token_type":"Bearer",
   "expires_in":3600,
   "access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjdkOTEyODNhMjc1NDdkNDRlMzNmOTc5ZjVmMGRkYzQwNzg1ZGY5NGFhMWI5MDVlZGNmMzg3NWIxYjJkZDMzNDljZWEyNjZhMTQ2OTE5OWIzIn0.eyJhdWQiOiJzdWl0ZWNybV9jbGllbnQiLCJqdGkiOiI3ZDkxMjgzYTI3NTQ3ZDQ0ZTMzZjk3OWY1ZjBkZGM0MDc4NWRmOTRhYTFiOTA1ZWRjZjM4NzViMWIyZGQzMzQ5Y2VhMjY2YTE0NjkxOTliMyIsImlhdCI6MTUxODE5NTEwMiwibmJmIjoxNTE4MTk1MTAyLCJleHAiOjE1MTgxOTg3MDIsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.EVGuRisoMxSIZut3IWtgOYISw8lEFSZgCWYCwseLEfOuPJ8lRMYL4OZxhu9gxJoGF0nj3yc6SYDPxovrsoj8bMoX38h4krMMOHFQLoizU0k2wAceOjZG1tWKPhID7KPT4TwoCXbb7MqAsYtVPExH4li7gSphJ8wvcWbFdS5em89Ndtwqq3faFtIq6bv1R4t0x98HHuT7sweHUJU40K9WQjbAfIOk8f5Y6T2wassN2wMCBB8CC6eUxLi14n2D6khHvkYvtPbXLHpXSHZWvEhqhvjAeSR5MmMrAth9WDSWUx7alO-ppsZpi8U7-g9Be5p6MRatc25voyTI2iTYbx02FQ",
   "refresh_token":"def50200d2fb757e4c01c333e96c827712dfd8f3e2c797db3e4e42734c8b4e7cba88a2dd8a9ce607358d634a51cadd7fa980d5acd692ab2c7a7da1d7a7f8246b22faf151dc11a758f9d8ea0b9aa3553f3cfd3751a927399ab964f219d086d36151d0f39c93aef4a846287e8467acea3dfde0bd2ac055ea7825dfb75aa5b8a084752de6d3976438631c3e539156a26bc10d0b7f057c092fce354bb10ff7ac2ab5fe6fd7af3ec7fa2599ec0f1e581837a6ca2441a80c01d997dac298e1f74573ac900dd4547d7a2a2807e9fb25438486c38f25be55d19cb8d72634d77c0a8dfaec80901c01745579d0f3822c717df21403440473c86277dc5590ce18acdb1222c1b95b516f3554c8b59255446bc15b457fdc17d5dcc0f06f7b2252581c810ca72b51618f820dbb2f414ea147add2658f8fbd5df20820843f98c22252dcffe127e6adb4a4cbe89ab0340f7ebe8d8177ef382569e2aa4a54d434adb797c5337bfdfffe27bd8d5cf4714054d4aef2372472ebb4"
}

[cols="15,80"]
|=======================================================================
|*token_type* |the Bearer token value

|*expires_in* |an integer representing the TTL of the access token

|*access_token* |a https://tools.ietf.org/html/rfc7519[JWT] signed with
the authorization server’s private key. It is required that you include
this in the HTTP headers, each time you make a request to the API

|*refresh_token* |an encrypted payload that can be used to refresh the
access token when it expires.
|=======================================================================

You can store the bearer token in a database and use in your requests
like this:

.Example
[source,php]
$header = array(
   'Content-type: application/vnd.api+json',
   'Accept: application/vnd.api+json',
   'Authorization: Bearer ' . $your_saved_access_token
);

== Refresh Token Grant

A refresh token grant is used if you already have a refresh token generated from password grant. It is used to get a new access token.

    "grant_type": "refresh_token",
    "client_id": "Client Id",
    "client_secret": "Client Secret",
    "refresh_token": "refresh token" (returned with password grant)
    
=== Getting Access Token using Refresh Grant

[source,php]
POST /Api/access_token

[[required-parameters-2]]
=== Required parameters

[width="40",cols="20,20",options="header",]
|======================================
|param |value
|grant_type |*refresh_token*
|client_id |*Client ID*
|client_secret |*Client Secret*
|refresh_token |*refresh token*
|======================================

Please change the values in bold to match your chosen authentication
details.
ß
.Example Request (PHP):
[source,php]
$ch = curl_init();
$header = array(
    'Content-type: application/vnd.api+json',
    'Accept: application/vnd.api+json',
 );
$postStr = json_encode(array(
    'grant_type' => 'refresh_token',
    'client_id' => '3D7f3fda97-d8e2-b9ad-eb89-5a2fe9b07650',
    'client_secret' => 'client_secret',
    'refresh_token' => 'refresh_token',
));
$url = 'https://path-to-instance/Api/access_token';
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
curl_setopt($ch, CURLOPT_POSTFIELDS, $postStr);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_HTTPHEADER, $header);
$output = curl_exec($ch);

.Example Response:
[source,php]
{
   "token_type":"Bearer",
   "expires_in":3600,
   "access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjdkOTEyODNhMjc1NDdkNDRlMzNmOTc5ZjVmMGRkYzQwNzg1ZGY5NGFhMWI5MDVlZGNmMzg3NWIxYjJkZDMzNDljZWEyNjZhMTQ2OTE5OWIzIn0.eyJhdWQiOiJzdWl0ZWNybV9jbGllbnQiLCJqdGkiOiI3ZDkxMjgzYTI3NTQ3ZDQ0ZTMzZjk3OWY1ZjBkZGM0MDc4NWRmOTRhYTFiOTA1ZWRjZjM4NzViMWIyZGQzMzQ5Y2VhMjY2YTE0NjkxOTliMyIsImlhdCI6MTUxODE5NTEwMiwibmJmIjoxNTE4MTk1MTAyLCJleHAiOjE1MTgxOTg3MDIsInN1YiI6IjEiLCJzY29wZXMiOltdfQ.EVGuRisoMxSIZut3IWtgOYISw8lEFSZgCWYCwseLEfOuPJ8lRMYL4OZxhu9gxJoGF0nj3yc6SYDPxovrsoj8bMoX38h4krMMOHFQLoizU0k2wAceOjZG1tWKPhID7KPT4TwoCXbb7MqAsYtVPExH4li7gSphJ8wvcWbFdS5em89Ndtwqq3faFtIq6bv1R4t0x98HHuT7sweHUJU40K9WQjbAfIOk8f5Y6T2wassN2wMCBB8CC6eUxLi14n2D6khHvkYvtPbXLHpXSHZWvEhqhvjAeSR5MmMrAth9WDSWUx7alO-ppsZpi8U7-g9Be5p6MRatc25voyTI2iTYbx02FQ",
   "refresh_token":"def50200d2fb757e4c01c333e96c827712dfd8f3e2c797db3e4e42734c8b4e7cba88a2dd8a9ce607358d634a51cadd7fa980d5acd692ab2c7a7da1d7a7f8246b22faf151dc11a758f9d8ea0b9aa3553f3cfd3751a927399ab964f219d086d36151d0f39c93aef4a846287e8467acea3dfde0bd2ac055ea7825dfb75aa5b8a084752de6d3976438631c3e539156a26bc10d0b7f057c092fce354bb10ff7ac2ab5fe6fd7af3ec7fa2599ec0f1e581837a6ca2441a80c01d997dac298e1f74573ac900dd4547d7a2a2807e9fb25438486c38f25be55d19cb8d72634d77c0a8dfaec80901c01745579d0f3822c717df21403440473c86277dc5590ce18acdb1222c1b95b516f3554c8b59255446bc15b457fdc17d5dcc0f06f7b2252581c810ca72b51618f820dbb2f414ea147add2658f8fbd5df20820843f98c22252dcffe127e6adb4a4cbe89ab0340f7ebe8d8177ef382569e2aa4a54d434adb797c5337bfdfffe27bd8d5cf4714054d4aef2372472ebb4"
}

[cols="15,80"]
|=======================================================================
|*token_type* |the Bearer token value

|*expires_in* |an integer representing the TTL of the access token

|*access_token* |a https://tools.ietf.org/html/rfc7519[JWT] signed with
the authorization server’s private key. It is required that you include
this in the HTTP headers, each time you make a request to the API

|*refresh_token* |an encrypted payload that can be used to refresh the
access token when it expires.
|=======================================================================

---
title: Getting Available Resources
weight: 40
---

:imagesdir: /images/en/developer

== Swagger Documentation
To see what resources and authentication methods are available, you can
retrieve the https://swagger.io/specification/[swagger documentation] via 2 routes

On the server the documentation is located at

[source]
{{suitecrm.url}}/Api/docs/swagger/swagger.json

You can also retrieve the documentation via an API call:

[source]
GET {{suitecrm.url}}/Api/V8/meta/swagger.json

The swagger documentation is a JSON file that includes information on what the default API is capable of and how to structure an API call.

An example of one of the paths included is shown below.
[source]
  "paths": {
    "/module/{moduleName}/{id}": {
      "get": {
        "tags": [
          "Module"
        ],
        "description": "Returns a bean with the specific ID",
        "parameters": [
          {
            "name": "moduleName",
            "in": "path",
            "description": "Name of the module",
            "required": true,
            "schema": {
              "type": "string"
            },
            "example": "Contacts"
          },
          {
            "name": "id",
            "in": "path",
            "description": "ID of the module",
            "required": true,
            "schema": {
              "type": "string",
              "format": "uuid"
            },
            "example": "b13a39f8-1c24-c5d0-ba0d-5ab123d6e899"
          },
          {
            "name": "fields[Contacts]",
            "in": "query",
            "description": "Filtering attributes of the bean",
            "schema": {
              "type": "string"
            },
            "example": "name,account_type"
          }
        ],
        "responses": {
          "200": {
            "description": "OK"
          },
          "400": {
            "description": "BAD REQUEST"
          }
        },
        "security": [
          {
            "oauth2": []
          }
        ]
      },
    },
  }

This will tell you everything you need to know about how to structure the API Request. A description of the array can be found below.

=== path

The path or URI of this api request i.e. "{{suitecrm.url}}/module/{moduleName}/{id}"

=== get

The type of request e.g. GET/POST/PATCH

=== description

Lets you know what this request is for.

=== parameters

Lets you know what can be included in the request.

* "name" is the name of the parameter or what it replaces in the path.
* "in" lets you know where this parameter should go.
** "path" means it replaces one of the varaiables in curly braces in the path.
** "query" means it should be included in the body of the request as a parameter.
* "required" lets you know if this parameter must be included for the API call to be successful.
* "schema" describes the type/format of the parameter.
* "example" provides an example of how the parameter is used in the API call.

=== responses

The http messages to expect with the API Response.

=== security

The required security for the API call.


---
title: Getting Available Resources
weight: 40
---

:imagesdir: /images/en/developer

== Swagger Documentation
To see what resources and authentication methods are available, you can
retrieve the https://swagger.io/specification/[swagger documentation] via 2 routes

On the server the documentation is located at

[source]
{{suitecrm.url}}/Api/docs/swagger/swagger.json

You can also retrieve the documentation via an API call:

[source]
GET {{suitecrm.url}}/Api/V8/meta/swagger.json

The swagger documentation is a JSON file that includes information on what the default API is capable of and how to structure an API call.

An example of one of the paths included is shown below.
[source]
  "paths": {
    "/module/{moduleName}/{id}": {
      "get": {
        "tags": [
          "Module"
        ],
        "description": "Returns a bean with the specific ID",
        "parameters": [
          {
            "name": "moduleName",
            "in": "path",
            "description": "Name of the module",
            "required": true,
            "schema": {
              "type": "string"
            },
            "example": "Contacts"
          },
          {
            "name": "id",
            "in": "path",
            "description": "ID of the module",
            "required": true,
            "schema": {
              "type": "string",
              "format": "uuid"
            },
            "example": "b13a39f8-1c24-c5d0-ba0d-5ab123d6e899"
          },
          {
            "name": "fields[Contacts]",
            "in": "query",
            "description": "Filtering attributes of the bean",
            "schema": {
              "type": "string"
            },
            "example": "name,account_type"
          }
        ],
        "responses": {
          "200": {
            "description": "OK"
          },
          "400": {
            "description": "BAD REQUEST"
          }
        },
        "security": [
          {
            "oauth2": []
          }
        ]
      },
    },
  }

This will tell you everything you need to know about how to structure the API Request. A description of the array can be found below.

=== path

The path or URI of this api request i.e. "{{suitecrm.url}}/module/{moduleName}/{id}"

=== get

The type of request e.g. GET/POST/PATCH

=== description

Lets you know what this request is for.

=== parameters

Lets you know what can be included in the request.

* "name" is the name of the parameter or what it replaces in the path.
* "in" lets you know where this parameter should go.
** "path" means it replaces one of the varaiables in curly braces in the path.
** "query" means it should be included in the body of the request as a parameter.
* "required" lets you know if this parameter must be included for the API call to be successful.
* "schema" describes the type/format of the parameter.
* "example" provides an example of how the parameter is used in the API call.

=== responses

The http messages to expect with the API Response.

=== security

The required security for the API call.

---
title: SuiteCRM V8 API Set Up For Postman
weight: 40
---

:imagesdir: /images/en/developer/API-Images/

== Steps to Set Up V8 API on Postman

== Composer

Install composer packages with

[source,php]
composer install

== .htaccess rebuild

Go to Admin Panel -> Repair -> Rebuild .htaccess File

image:htaccess_rebuild.png[Rebuild of .htaccess]

== Import Collection File into Postman

1 - Click Import

image:import_Files.png[Import Collection File]

2 - Import collection file. You can find it in `Api/docs/postman`

{{% notice note %}}
If you can't find your collection file it may been in a directory that postman can't upload from -
Solution: Move collection file into `documents`.
{{% /notice %}}

=== Setup Environment

1 - Click Manage Environments -> Add

2 - Set Environment name - Example: SuiteCRM V8 API Environment

3 - Fill table out as shown below:

.Manage Environments
|===
|VARIABLE |INITIAL VALUE |CURRENT VALUE

|suitecrm.url
|\http://{{IP ADDRESS}}/{{Your Instance}}/Api
|\http://{{IP ADDRESS}}/{{Your Instance}}/Api

|token.url
|\http://{{IP ADDRESS}}/{{Your Instance}}/Api/access_token
|\http://{{IP ADDRESS}}/{{Your Instance}}/Api/access_token
|===

-> Add

4 - Click Environment from the Drop down

image:change_environment.png[Changing Environment]


---
title: Customization
weight: 60
---

:imagesdir: /images/en/developer


== Customization

Each customization should be in a base folder `custom/application/Ext/Api/V8/`.
See more about Slim framework at https://www.slimframework.com.

Extending Slim configuration in `custom/application/Ext/Api/V8/slim.php` is a native php file should returns an array of slim configurations.
Additional configuration will be merged into the default slim configuration.
[source,php]
return [ /* slim configuration here ...*/ ];


Extending Routes in `custom/application/Ext/Api/V8/Config/routes.php` is a native php file given `$app` variable as a Slim application.
Additional routes will be added into the default slim application and available in URL [SuiteCRM-path]/Api/V8/custom
custom/application/Ext/Api/V8/Config/routes.php
[source,php]
// example for custom POST route entry:
$app->post('/my-route/{myParam}', 'MyCustomController:myCustomAction');


Extending Services in `custom/application/Ext/Api/V8/services.php` is a native php file should returns an array of slim services.
Additional services will be merged into the default slim services.
custom/application/Ext/Api/V8/services.php
[source,php]
// example of custom service:
return ['myCustomService' => function() {
    return new MyCustomService();
}];


Extending BeanAliases in `custom/application/Ext/Api/V8/beanAliases.php` is a native php file should returns an array of custom bean aliases.
custom/application/Ext/Api/V8/beanAliases.php
[source,php]
// example of custom service:
return [MyCustom::class => 'MyCustoms'];


Extending Controllers in `custom/application/Ext/Api/V8/controllers.php` is a native php file should returns an array of custom controllers.
custom/application/Ext/Api/V8/controllers.php
[source,php]
// example of custom controllers:
return [MyCustomController::class => function(Container $container) {
    return new MyCustomController();
}];


Extending Factories in `custom/application/Ext/Api/V8/factories.php` is a native php file should returns an array of custom factories.
custom/application/Ext/Api/V8/factories.php
[source,php]
// example of custom factories:
return [MyCustomFactory::class => function(Container $container) {
    return new MyCustomFactory();
}];


Extending Globals in `custom/application/Ext/Api/V8/globals.php` is a native php file should returns an array of custom globals.
custom/application/Ext/Api/V8/globals.php
[source,php]
// example of custom globals:
return [MyCustomGlobal::class => function(Container $container) {
    return new MyCustomFactory();
}];


Extending Helpers in `custom/application/Ext/Api/V8/helpers.php` is a native php file should returns an array of custom helpers.
custom/application/Ext/Api/V8/helpers.php
[source,php]
// example of custom helpers:
return [MyCustomHelper::class => function(Container $container) {
    return new MyCustomHelper();
}];



Extending Middlewares in `custom/application/Ext/Api/V8/middlewares.php` is a native php file should returns an array of custom middlewares.
custom/application/Ext/Api/V8/middlewares.php
[source,php]
// example of custom middlewares:
return [MyCustomMiddleware::class => function(Container $container) {
    return new MyCustomMiddleware();
}];



Extending Params in `custom/application/Ext/Api/V8/params.php` is a native php file should returns an array of custom params.
custom/application/Ext/Api/V8/params.php
[source,php]
// example of custom params:
return [MyCustomParam::class => function(Container $container) {
    return new MyCustomParam();
}];



Extending Validators in `custom/application/Ext/Api/V8/validators.php` is a native php file should returns an array of custom validators.
custom/application/Ext/Api/V8/validators.php
[source,php]
// example of custom validators:
return [MyCustomValidator::class => function(Container $container) {
    return new MyCustomValidator();
}];


=== Basic example of API customization
Create a file for new custom route: `[SuiteCRM-path]/custom/application/Ext/Api/V8/Config/routes.php` with the following content:
[source,php]
<?php
$app->get('/hello', function() {
    return 'Hello World!';
});



---
Title: JSON API Error Object
---

== JsonApiErrorObject class

Implementation of JSON API Error Object Specification. 
See more: http://jsonapi.org/format/#error-objects[^]

== Usage

[source,php]
--

// creating a new Error Object:
$error = new JsonApiErrorObject();

// set some known data about the error:
$error->setTitle(new LangText('LBL_ERROR_LABEL_TITLE'));
$error->setDetail(new LangText('LBL_ERROR_LABEL_DETAIL'));
$error->setCode(ERROR_CODE);
// etc.. see more in source and phpDoc

// creating new Error Object with known data directly in constructor, all parameters are optional:
$error = new JsonApiErrorObject(
    // title: a short, human-readable summary of the problem that SHOULD NOT change from occurrence to occurrence of the problem, except for purposes of localization.
    new LangText('LBL_ERROR_LABEL_TITLE'),      
    // detail: a human-readable explanation specific to this occurrence of the problem. Like title, this field’s value can be localized.
    new LangText('LBL_ERROR_LABEL_DETAIL'),     
    // id: a unique identifier for this particular occurrence of the problem.
    ERROR_ID,                                   
    // code: an application-specific error code, expressed as a string value.
    ERROR_CODE,                                 
    // status: the HTTP status code applicable to this problem, expressed as a string value.
    STATUS,                                     
    // links: a links object
    ['about' => 'Description about the problem'],
    // source: an object containing references to the source of the error
    ['pointer' => '/test/foo/bar', 'parameter' => 'wrong'], 
    // meta: a meta object containing non-standard meta-information about the error.
    ['some' => 'meta info']                     
);

// retrieving Error Object from an Exception:
try {
  // ...do stuff
} catch (Exception $e) {
  $error->retrieveFromException($e)
}

// retrieving Error object from a ServerRequestInterface:
$error->retrieveFromRequest($request);

// converting to an array:
$array = $error->export();

// converting to a JSON string:
$json = $error->exportJson();

--
