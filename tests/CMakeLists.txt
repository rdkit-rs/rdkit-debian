cmake_minimum_required(VERSION 3.18)
project(RDKitPackageConsumer LANGUAGES CXX)
find_package(rdkit 2026.09.1 EXACT CONFIG REQUIRED)
add_executable(consumer main.cpp bridge.cpp)
target_compile_features(consumer PRIVATE cxx_std_20)
target_link_libraries(consumer PRIVATE RDKit::SmilesParse RDKit::Descriptors
    RDKit::Fingerprints RDKit::MolStandardize RDKit::MolChemicalFeatures
    RDKit::RDInchiLib RDKit::SubstructMatch)
