import Foundation
import SmartyStreets

class USStreetMultipleAddressExample {
    func run() -> String {
        //            The appropriate license values to be used for your subscriptions
        //            can be found on the Subscriptions page of the account dashboard.
        //            https://www.smartystreets.com/docs/cloud/licensing
        //            We recommend storing your authentication credentials in environment variables.
        //            for server-to-server requests, use this code:
        //let authId = getEnvironmentVar("SMARTY_AUTH_ID") ?? ""
        //let authToken = getEnvironmentVar("SMARTY_AUTH_TOKEN") ?? ""
        //let client = ClientBuilder(authId:authId, authToken:authToken).buildUsStreetApiClient()
        
        // for client-side requests (browser/mobile), use this code:
        let id = getEnvironmentVar("SMARTY_AUTH_WEB") ?? ""
        let hostname = getEnvironmentVar("SMARTY_AUTH_REFERER") ?? ""
        let client = ClientBuilder(id: id, hostname: hostname).buildUsStreetApiClient()
                
        let batch = USStreetBatch()
        var error:NSError! = nil
        
        //        Documentation for input fields can be found at:
        //        https://smartystreets.com/docs/us-street-api#input-fields
        let address1 = USStreetLookup()
        address1.inputId = "24601"
        address1.addressee = "John Doe"
        address1.street = "1600 amphitheatre parkway"
        address1.street2 = "closet under the stairs"
        address1.secondary = "APT 2"
        address1.urbanization = "" // Only applies to Puerto Rico addresses
        address1.lastline = "Mountain view, california"
        address1.maxCandidates = 5
        address1.matchStrategy = "invalid" // "invalid" is the most permissive match,
                                           // this will always return at least one result even if the address is invalid.
                                           // Refer to the documentation for additional Match Strategy options.
        
        let address2 = USStreetLookup(freeformAddress: "1 Rosedale, Baltimore, Maryland")
        address2.setMaxCandidates(max: 10, error: &error)
        
        let address3 = USStreetLookup(freeformAddress: "123 Bogus Street, Pretend Lake, Oklahoma")
        
        let address4 = USStreetLookup()
        address4.inputId = "8675309"
        address4.street = "1 Infinite Loop"
        address4.zipCode = "95014"
        address4.maxCandidates = 1
        
        _ = batch.add(newAddress: address1, error: &error)
        _ = batch.add(newAddress: address2, error: &error)
        _ = batch.add(newAddress: address3, error: &error)
        _ = batch.add(newAddress: address4, error: &error)
        
        if let error = error {
            let output = """
                Domain: \(error.domain)
                Error Code: \(error.code)
                Description:\n\(error.userInfo[NSLocalizedDescriptionKey] as! NSString)
                """
            return output
        }
        
        _ = client.sendBatch(batch: batch, error: &error)
        
        if let error = error {
            let output = """
            Domain: \(error.domain)
            Error Code: \(error.code)
            Description:\n\(error.userInfo[NSLocalizedDescriptionKey] as! NSString)
            """
            return output
        }
        
        let lookups:[USStreetLookup] = batch.allLookups as! [USStreetLookup]
        var output = "Results\n"
        
        for i in 0..<batch.count() {
            let candidates:[USStreetCandidate] = lookups[i].result
            
            if candidates.count == 0 {
                output.append( "\nAddress \(i) is invalid\n")
            }
            
            for candidate in candidates {
                output.append("""
                    There is at least one candidate.\n If the match parameter is set to STRICT, the address is valid.\n Otherwise, check the Analysis output fields to see if the address is valid.\n\n
                    \nZIP Code: \(candidate.components?.zipCode ?? "")
                    \nCounty: \(candidate.metadata?.countyName ?? "")
                    \nLatitude: \(candidate.metadata?.latitude ?? 0.0)
                    \nLongitude: \(candidate.metadata?.longitude ?? 0.0)
                    """)
            }
            
            output.append("\n*******************************************\n")
        }
        return output
    }
}
