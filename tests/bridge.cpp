#include <GraphMol/SmilesParse/SmilesParse.h>
#include <GraphMol/SmilesParse/SmilesWrite.h>
#include <GraphMol/Substruct/SubstructMatch.h>
#include <GraphMol/Descriptors/MolDescriptors.h>
#include <GraphMol/Fingerprints/MorganFingerprints.h>
#include <GraphMol/MolStandardize/MolStandardize.h>
#include <GraphMol/MolChemicalFeatures/MolChemicalFeatureFactory.h>
#include <GraphMol/inchi.h>
#include <RDGeneral/versions.h>
#include <cmath>
#include <cstdlib>
#include <fstream>
#include <future>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

extern "C" int rdkit_reference_smoke() {
    try {
        auto require = [](bool condition) {
            if (!condition) throw std::runtime_error("RDKit smoke assertion failed");
        };
        require(std::string(RDKit::rdkitVersion) == "2026.09.1");
        std::unique_ptr<RDKit::RWMol> mol(RDKit::SmilesToMol("CCO"));
        require(mol && mol->getNumAtoms() == 3);
        require(RDKit::MolToSmiles(*mol) == "CCO");
        require(std::abs(RDKit::Descriptors::calcExactMW(*mol) - 46.041864812) < 0.0001);
        std::unique_ptr<ExplicitBitVect> fp(
            RDKit::MorganFingerprints::getFingerprintAsBitVect(*mol, 2, 2048));
        require(fp->getNumBits() == 2048 && fp->getNumOnBits() > 0);
        std::unique_ptr<RDKit::RWMol> salt(RDKit::SmilesToMol("CCO.[Na+]"));
        std::unique_ptr<RDKit::RWMol> parent(RDKit::MolStandardize::fragmentParent(*salt));
        require(RDKit::MolToSmiles(*parent) == "CCO");
        RDKit::ExtraInchiReturnValues inchi_result;
        require(RDKit::MolToInchi(*mol, inchi_result) == "InChI=1S/C2H6O/c1-2-3/h3H,2H2,1H3");
        const char *base = std::getenv("RDBASE");
        require(base != nullptr);
        std::ifstream definitions(std::string(base) + "/Data/BaseFeatures.fdef");
        require(definitions.good());
        std::unique_ptr<RDKit::MolChemicalFeatureFactory> factory(RDKit::buildFeatureFactory(definitions));
        require(!factory->getFeaturesForMol(*mol).empty());
        std::unique_ptr<RDKit::RWMol> query(RDKit::SmartsToMol("CO"));
        std::vector<std::future<bool>> workers;
        for (int i = 0; i < 4; ++i) {
            workers.push_back(std::async(std::launch::async, [&] {
                return !RDKit::SubstructMatch(*mol, *query).empty();
            }));
        }
        for (auto &worker : workers) require(worker.get());
        return 0;
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    } catch (...) {
        return 2;
    }
}
