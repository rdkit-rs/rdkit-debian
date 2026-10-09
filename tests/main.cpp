#include <iostream>
extern "C" int rdkit_reference_smoke();
int main() {
    int status = rdkit_reference_smoke();
    if (status == 0) std::cout << "RDKit 2026.09.1 installed C++ smoke passed\n";
    return status;
}
