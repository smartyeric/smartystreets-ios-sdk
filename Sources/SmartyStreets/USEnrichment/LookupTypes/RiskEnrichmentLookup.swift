import Foundation

public class RiskEnrichmentLookup: EnrichmentLookup {
    
    public var results:[RiskResult]?
    
    init(smartyKey: String){
        self.results = nil
        super.init(smartyKey: smartyKey, datasetName: "risk", dataSubsetName: "")
    }
    
    init(lookup: EnrichmentLookup) {
        self.results = nil
        super.init(smartyKey: lookup.getSmartyKey(), datasetName: "risk", dataSubsetName: "")
        for key in lookup.getIncludeAttributes() {
            self.addIncludeAttribute(attribute: key)
        }
        for key in lookup.getExcludeAttributes() {
            self.addExcludeAttribute(attribute: key)
        }
        self.setStreet(street: lookup.getStreet())
        self.setCity(city: lookup.getCity())
        self.setState(state: lookup.getState())
        self.setZipcode(zipcode: lookup.getZipcode())
        self.setFreeform(freeform: lookup.getFreeform())
        self.setEtag(etag: lookup.getEtag())
        for key in lookup.getCustomParamArray().keys {
            self.addCustomParameter(parameter: key, value: lookup.getCustomParamArray()[key] ?? "")
        }
    }
    
    override public func deserializeAndSetResults(serializer: SmartySerializer, payload: Data, error: UnsafeMutablePointer<NSError?>) {
        self.results = serializer.Deserialize(payload: payload, error: &error.pointee) as? [RiskResult]
    }
}
