use std::{env, path::PathBuf, process::Command};

fn output(args: &[&str]) -> String {
    let result = Command::new("pkg-config").args(args).output().unwrap();
    assert!(result.status.success(), "pkg-config failed");
    String::from_utf8(result.stdout).unwrap()
}

fn main() {
    let out = PathBuf::from(env::var_os("OUT_DIR").unwrap());
    let object = out.join("bridge.o");
    let mut compiler = Command::new("c++");
    compiler.args(output(&["--cflags", "rdkit"]).split_whitespace());
    assert!(compiler.args(["-c", "../bridge.cpp", "-o"]).arg(&object).status().unwrap().success());
    assert!(Command::new("ar").arg("crs").arg(out.join("libpackage_bridge.a")).arg(&object).status().unwrap().success());
    println!("cargo:rustc-link-search=native={}", out.display());
    println!("cargo:rustc-link-lib=static=package_bridge");
    for flag in output(&["--libs", "rdkit"]).split_whitespace() {
        if let Some(path) = flag.strip_prefix("-L") {
            println!("cargo:rustc-link-search=native={path}");
        } else if let Some(lib) = flag.strip_prefix("-l") {
            println!("cargo:rustc-link-lib=dylib={lib}");
        } else {
            println!("cargo:rustc-link-arg={flag}");
        }
    }
    println!("cargo:rustc-link-lib=dylib=RDKitMolChemicalFeatures");
    println!("cargo:rustc-link-lib=dylib=stdc++");
    println!("cargo:rerun-if-changed=../bridge.cpp");
}
