# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  gdu_static = pkgs.gdu.overrideAttrs (oldAttrs: rec {
    CGO_ENABLED = "0";
  });
  gh_static = pkgs.gh.overrideAttrs (oldAttrs: rec {
    CGO_ENABLED = "0";
  });
  bazelisk_static = pkgs.bazelisk.overrideAttrs (oldAttrs: rec {
    CGO_ENABLED = "0";
  });
  croc_static = pkgs.croc.overrideAttrs (oldAttrs: rec {
    CGO_ENABLED = "0";
  });
  go_task_static = pkgs.go-task.overrideAttrs (oldAttrs: rec {
    CGO_ENABLED = "0";
  });
  git_lfs_static = pkgs.git-lfs.overrideAttrs (oldAttrs: rec {
    CGO_ENABLED = "0";
  });
  gost_static = pkgs.gost.overrideAttrs (oldAttrs: rec {
    CGO_ENABLED = "0";
  });
  shfmt_static = pkgs.shfmt.overrideAttrs (oldAttrs: rec {
    CGO_ENABLED = "0";
  });
  fzf_static = pkgs.fzf.overrideAttrs (oldAttrs: rec {
    CGO_ENABLED = "0";
  });
  silver_searcher_static = pkgs.pkgsStatic.silver-searcher.overrideAttrs (oldAttrs: rec {
    NIX_LDFLAGS = "";
  });
  diffutils_static = pkgs.pkgsStatic.diffutils.overrideAttrs (oldAttrs: rec {
    doCheck = false;
  });
  wget_static = pkgs.pkgsStatic.wget.overrideAttrs (oldAttrs: rec {
    nativeBuildInputs = [ pkgs.gettext pkgs.pkg-config pkgs.lzip pkgs.libiconv pkgs.libintl ];
    doCheck = false;
  });
  zsh_static = pkgs.pkgsStatic.zsh.overrideAttrs (oldAttrs: rec {
    patchPhase = oldAttrs.patchPhase or "" + ''
      echo "link=either" >> Src/Modules/system.mdd
      echo "link=either" >> Src/Modules/regex.mdd
      echo "link=either" >> Src/Modules/mathfunc.mdd
    '';
  });
  protobuf3_20_static = pkgs.pkgsStatic.protobuf3_20.overrideAttrs (oldAttrs: rec {
    postInstall = ''
      mv $out/bin/protoc $out/bin/protoc-${oldAttrs.version}
    '';
  });
  protobuf_3_8_0_static = pkgs.pkgsStatic.protobuf3_20.overrideAttrs (oldAttrs: rec {
    src = pkgs.fetchFromGitHub {
      owner = "protocolbuffers";
      repo = "protobuf";
      rev = "v3.8.0";
      sha256 = "sha256-qK4Tb6o0SAN5oKLHocEIIKoGCdVFQMeBONOQaZQAlG4=";
    };
    postInstall = ''
      mv $out/bin/protoc $out/bin/protoc-3.8.0
    '';
  });
  protobuf_3_9_2_static = pkgs.pkgsStatic.protobuf3_20.overrideAttrs (oldAttrs: rec {
    src = pkgs.fetchFromGitHub {
      owner = "protocolbuffers";
      repo = "protobuf";
      rev = "v3.9.2";
      sha256 = "sha256-1mLSNLyRspTqoaTFylGCc2JaEQOMR1WAL7ffwJPqHyA=";
    };
    postInstall = ''
      mv $out/bin/protoc $out/bin/protoc-3.9.2
    '';
  });
  cmake_static = pkgs.pkgsStatic.cmakeMinimal.overrideAttrs (oldAttrs: rec {
    doCheck = false;
  });
  git_static = pkgs.pkgsStatic.git.overrideAttrs (oldAttrs: rec {
    preInstallCheck = oldAttrs.preInstallCheck + ''
      disable_test t0211-trace2-perf
      disable_test t2082-parallel-checkout-attributes
      disable_test t1517-outside-repo
    '';
  });
  dstat_static = pkgs.pkgsStatic.dstat.overrideAttrs (oldAttrs: rec {
    doCheck = false;
    pytestCheckPhase = "";
    preDistPhases = [];
    installCheckPhase = false;
  });
  python311_static = pkgs.pkgsStatic.python311.overrideAttrs (oldAttrs: rec {
    # https://wiki.python.org/moin/BuildStatically
    # https://github.com/python/cpython/blob/3.11/Modules/Setup
    configureFlags = oldAttrs.configureFlags ++ [
      "LDFLAGS=-L${pkgs.pkgsStatic.termcap}/lib"
      #"--with-ensurepip=install"
    ];
    stripIdlelib = true;
    stripTests = true;
    stripTkinter = true;
    postPatch = oldAttrs.postPatch + ''
      #sed -i 's/#*shared*/#*static*/g' Modules/Setup
      cat <<EOF >> Modules/Setup.local
        _asyncio _asynciomodule.c
        _bisect _bisectmodule.c
        _contextvars _contextvarsmodule.c
        _csv _csv.c
        _datetime _datetimemodule.c
        _decimal _decimal/_decimal.c
        _heapq _heapqmodule.c
        _json _json.c
        _lsprof _lsprof.c rotatingtree.c
        _multiprocessing -I$(srcdir)/Modules/_multiprocessing _multiprocessing/multiprocessing.c _multiprocessing/semaphore.c
        _opcode _opcode.c
        _pickle _pickle.c
        _queue _queuemodule.c
        _random _randommodule.c
        _socket socketmodule.c
        _statistics _statisticsmodule.c
        _struct _struct.c
        _typing _typingmodule.c
        _zoneinfo _zoneinfo.c
        array arraymodule.c
        audioop audioop.c
        binascii binascii.c
        cmath cmathmodule.c
        math mathmodule.c
        mmap mmapmodule.c
        select selectmodule.c

        _blake2 _blake2/blake2module.c _blake2/blake2b_impl.c _blake2/blake2s_impl.c
        _md5 md5module.c
        _sha1 sha1module.c
        _sha256 sha256module.c
        _sha512 sha512module.c
        _sha3 _sha3/sha3module.c
        unicodedata unicodedata.c

        _posixsubprocess _posixsubprocess.c
        _posixshmem -I$(srcdir)/Modules/_multiprocessing _multiprocessing/posixshmem.c -lrt
        fcntl fcntlmodule.c
        grp grpmodule.c
        ossaudiodev ossaudiodev.c
        resource resource.c
        spwd spwdmodule.c
        syslog syslogmodule.c
        termios termios.c

        _elementtree _elementtree.c
        pyexpat pyexpat.c

        _bz2 _bz2module.c -lbz2
        _ctypes _ctypes/_ctypes.c _ctypes/callbacks.c _ctypes/callproc.c _ctypes/stgdict.c _ctypes/cfield.c -ldl -lffi -DHAVE_FFI_PREP_CIF_VAR -DHAVE_FFI_PREP_CLOSURE_LOC -DHAVE_FFI_CLOSURE_ALLOC
        _dbm _dbmmodule.c -lgdbm_compat -DUSE_GDBM_COMPAT
        _gdbm _gdbmmodule.c -lgdbm
        _lzma _lzmamodule.c -llzma
        #_uuid _uuidmodule.c -luuid
        zlib  zlibmodule.c -lz

        _ssl _ssl.c $(OPENSSL_INCLUDES) $(OPENSSL_LDFLAGS) $(OPENSSL_LIBS)
        _hashlib _hashopenssl.c $(OPENSSL_INCLUDES) $(OPENSSL_LDFLAGS) -lcrypto

         _ssl _ssl.c $(OPENSSL_INCLUDES) $(OPENSSL_LDFLAGS) \
             -l:libssl.a -Wl,--exclude-libs,libssl.a \
             -l:libcrypto.a -Wl,--exclude-libs,libcrypto.a
         _hashlib _hashopenssl.c $(OPENSSL_INCLUDES) $(OPENSSL_LDFLAGS) \
             -l:libcrypto.a -Wl,--exclude-libs,libcrypto.a

        _curses -lncurses -lncursesw -ltermcap _cursesmodule.c
        _curses_panel -lpanel -lncurses _curses_panel.c

EOF
    '';
  });
in
{
  inherit bazelisk_static;
  inherit croc_static;
  inherit gdu_static;
  inherit gh_static;
  inherit git_lfs_static;
  inherit go_task_static;
  inherit gost_static;
  inherit silver_searcher_static;
  inherit shfmt_static;
  inherit fzf_static;
  inherit zsh_static;
  inherit wget_static;
  inherit diffutils_static;
  inherit protobuf3_20_static;
  inherit python311_static;
  inherit dstat_static;
  inherit git_static;
  inherit protobuf_3_8_0_static;
  inherit protobuf_3_9_2_static;

  rsync_static = pkgs.pkgsStatic.rsync.override {
    enableXXHash = false;
  };
  coreutils_static = pkgs.pkgsStatic.coreutils.override {
    singleBinary = false;
  };
  gnupg_minimal_static = pkgs.pkgsStatic.gnupg.override {
    enableMinimal = true;
  };
}
