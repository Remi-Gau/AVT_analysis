# Use sphinx to create a matlab doc

## Set up virtual environment

```bash
virtualenv -p python3 avt
source avt/bin/activate

pip install -r requirements.txt
```

## TIPS

To get the filenames of all the functions in a folder:

``` bash
ls -l src/*.m | cut -c42- | rev | cut -c 3- | rev
```

Increase the `42` to crop more characters at the beginning.

Change the `3` to crop more characters at the end.

## Build the documentation locally

From the `docs` directory:

```bash
sphinx-build -b html source build
```

This will build an html version of the doc in the `build` folder.

