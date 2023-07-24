{ pkgs ? import <nixpkgs> {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "openssl-1.1.1u"
      ];
    };
  } 
}:
let
  msodbcsql = pkgs.unixODBCDrivers.msodbcsql17;
  odbcConfiguration = pkgs.writeTextFile {
    name = "odbc-configuration";
    text = ''
      [${msodbcsql.fancyName}]
      Description = ${msodbcsql.meta.description}
      Driver = ${msodbcsql}/${msodbcsql.driver}
    '';
    destination = "/odbcinst.ini";
  };

  unixODBC = pkgs.unixODBC.overrideAttrs (oldAttrs: {
    configureFlags = [ "--disable-gui" "--sysconfdir=${odbcConfiguration}" ];
  });
in
pkgs.mkShell rec {
  runtimeInputs = [
    unixODBC
    msodbcsql
    pkgs.openssl_1_1
  ];

  buildInputs = [
    pkgs.haskell.compiler.ghc94
    pkgs.haskell.packages.ghc94.cabal-install
  ] ++ runtimeInputs;

  LD_LIBRARY_PATH = pkgs.lib.strings.makeLibraryPath runtimeInputs;
}
