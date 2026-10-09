extern "C" {
    fn rdkit_reference_smoke() -> i32;
}

fn main() {
    assert_eq!(unsafe { rdkit_reference_smoke() }, 0);
    println!("Rust consumer linked to installed RDKit 2026.09.1 passed");
}

#[test]
fn installed_rdkit_chemical_operations() {
    assert_eq!(unsafe { rdkit_reference_smoke() }, 0);
}
