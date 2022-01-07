# rbrownwsws/postfix

A container image for running the [`postfix`](http://www.postfix.org/) MTA.

## How to use this image

You can configure `postfix` by passing envrionment variables to the container as described below.

### Configuring `main.cf` parameters

Pass an environment variable to the container in this form:

`POSTCONF_MAIN_PARAM_<parameter>=<value>`

> **Example**
>
> If you would normally configure the parameter by running:
>
> `postconf -e "myhostname=example.com"`
>
> You should pass the container this environment variable instead:
>
> `POSTCONF_MAIN_PARAM_MYHOSTNAME=example.com`

### Configuring `master.cf` entries

Pass an environment variable to the container in this form:

`POSTCONF_MASTER_ENTRY_<service>_<type>=<value>`

> **Example**
>
> If you would normally configure the entry by running:
>
> `postconf -M -e "smtp/inet=smtp inet n - n - - smtpd"`
>
> You should pass the container this environment variable instead:
>
> `POSTCONF_MASTER_ENTRY_SMTP_INET="smtp inet n - n - - smtpd"`

### Configuring `master.cf` parameters

Pass an environment variable to the container in this form:

`POSTCONF_MASTER_PARAM_<service>_<type>_<parameter>=<value>`

> **Example**
>
> If you would normally configure the parameter by running:
>
> `postconf -P -e "smtp/inet/smtpd_tls_security_level=may"`
>
> You should pass the container this environment variable instead:
>
> `POSTCONF_MASTER_PARAM_SMTP_INET_SMTPD_TLS_SECURITY_LEVEL=may`

### Postfix lookup tables

Pass an environment variable to the container in this form:

`POSTMAP_<file_type>_<file_name>=<input_file_content>`

_N.B. Files will be created in `/etc/postfix/<file_name>`_

> **Example**
>
> If you normally had this file:
>
> >_/etc/postfix/virtual_
> >
> > @example.com john@gmail.com
>
> and would run:
>
> `postmap "lmdb:/etc/postfix/virtual"`
>
> You should pass the container this environment variable instead:
>
> `POSTMAP_LMDB_VIRTUAL="@example.com john@gmail.com"`
