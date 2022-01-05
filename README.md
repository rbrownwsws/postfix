# rbrownwsws/postfix

A container image for running the [`postfix`](http://www.postfix.org/) MTA.

## How to use this image

You can configure `postfix` by passing envrionment variables to the container as described below.

### Configuring `main.cf`

Pass an environment variable to the container in this form:

`POSTCONF_MAIN_<parameter>=<value>`

> **Example**
> 
> If you would normally configure the parameter by running:
> 
> `postconf -e "myhostname=example.com"`
>
> You should pass the container this environment variable instead:
>
> `POSTCONF_MAIN_MYHOSTNAME=example.com`

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
