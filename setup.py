from setuptools import setup
setup(
    name="iona",
    package_dir={"":"py"},
    py_modules=["gcpblob", "gcpsecrets", "josekeys"],
    entry_points=dict(
        console_scripts=["josekeys=josekeys:run"]
    ),
    install_requires=[
        "coincurve",
        # "cryptography",
        # "eth-keys",
        "google-auth",
        "google-cloud-secret-manager",
        "jwcrypto",
        "pysha3",
        "requests"
    ]
)
