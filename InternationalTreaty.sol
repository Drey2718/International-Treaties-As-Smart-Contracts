// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract InternationalTreaty {
    //variables:
    string public treatyName; //treaty's name
    string public treatyTitle; //treaty's title
    string public treatyPreamble; //treaty's preamble
    string public treatyUniqueIDCode; //string variable for the treaty's uniquie Identification Code,
                                    //every Treaty will have a unique code that identifies the treaty 
                                    //so as to aviod ambiquity and confusion.

    string[] public articlesOfTreaty; //articles (clauses) of the treaty                             
    string[] public authorsOfTreaty; //authors of treaty - specifically articles
    
    
    //SETTERS:
    function setTreatyName(string memory _treatyName) public  {
        treatyName = _treatyName;
    }

    function setTreatyTitle(string memory _treatyTitle) public {
        treatyTitle = _treatyTitle;
    }

    function setTreatyPreamble(string memory _treatyPreamble) public {
        treatyPreamble = _treatyPreamble;
    }

    function setTreatyUniqueIDCode(string memory _treatyUniqueIDCode) public {
        treatyUniqueIDCode = _treatyUniqueIDCode;
    }

    //GETTERS:
    function getTreatyName() public view returns(string memory) {
        return treatyName;
    }

    function getTreatyTitle() public view returns(string memory) {
        return treatyTitle;
    }

    function getTreatyPreamble() public view returns(string memory) {
        return treatyPreamble;
    }

    function getArticlesOfTreaty() public  view  returns(string[] memory) {
        return articlesOfTreaty;
    }

    function getArticle(uint index) public view returns (string memory) {
        return articlesOfTreaty[index];
    }

    function getNumberOfArticlesInTreaty() public view returns (uint) {
        return articlesOfTreaty.length;
    }


    //OTHER:
    //Mapping of articles to repsective numbers
    mapping (string => uint) public articleToNumbers;
    mapping (uint => string) public designatedNumbersToArticles;

    //Function to add an article to the Treaty
    //note: the designated article number may not necessarily correspond to the index of the article
    //e.g. an auther may enter article 1 but article 1 have an index of 3 (3rd Article) or index 0.
    function addArticle(string memory _article, uint _articleNum, string memory _auth) public  {
        if (bytes(_article).length > 0 && bytes(_auth).length > 0){
            articlesOfTreaty.push(_article);
            authorsOfTreaty.push(_auth);
            articleToNumbers[_article] = _articleNum;
            designatedNumbersToArticles[_articleNum] = _article;
        } else {
            revert("Articles must have authors");
        }
    }

    //Function to remove an article from the Treaty
     function removeArticle(uint indexOfArticle, uint _theArticleNumber, string memory _authWhoRemoved) public {
        if (bytes(_authWhoRemoved).length > 0) {
            if (indexOfArticle >= articlesOfTreaty.length) {
            revert("Index is out of bounds");
            }

            for (uint i = indexOfArticle; i < articlesOfTreaty.length - 1; i++) {
            articlesOfTreaty[i] = articlesOfTreaty[i + 1];
            }

            designatedNumbersToArticles[_theArticleNumber] = string.concat("REMOVED BY: ", _authWhoRemoved);
            articlesOfTreaty.pop();
        } else {
            revert("Author's name must be entered to remove an article");
        }
    }


    // Mapping of country codes to their respective signatory status
    mapping (string => bool) public signatoriesCountries;
    // Mapping of delegates (authorized representatives/diplomats) of formalized governments to their respective signatory status
    mapping (string => bool) public signatoriesDelegates;

    string[] public delegates; //array of delegates, names of (authorized representatives): 
                                //who have the officiating status commisioned/ordained by their 
                                //respective governments to officially sign treaties on behalf of their governments

    //Mapping of delegates to countries (country codes)
     mapping (string => string) public signatoriesDelegatesToCountries;
     

    //Function to add a delegate to the delegates array
    function addDelegate(string memory _delegateName, string memory _countryCode) public {
        if (bytes(_delegateName).length > 0 && bytes(_countryCode).length > 0) {
            delegates.push(_delegateName);
            signatoriesDelegatesToCountries[_delegateName] = _countryCode;

            
        } else {
            revert("Every Delegate Must have a corresponding Country code, vise versa");
        }
         
    }

    //Function to remove a delegate by name
    function removeDelegate(string memory _nameOfDelegate) public {
        for (uint i = 0; i < delegates.length; i++) {
            if (keccak256(abi.encodePacked(delegates[i])) == keccak256(abi.encodePacked(_nameOfDelegate))) {
                delegates[i] = delegates[delegates.length - 1];
                delegates.pop();
                break;
            }
        }
    }                        

    // Event emitted when a country signs the treaty
    event TreatySigned(string countryCode);

    event TreatySignedByDelegate(string individualDelegateName);

    // Function to sign the treaty - treaty can only be siged if all 
    // authorized/commissioned delegates tasked with conducting such actions in this Bilateral treaty case 
    // have signed (convention used since a treaty has no tangible effect if only 1 party signs but the other does not.)
    
    function signTreaty(string memory _countryCode) public {
        require(!signatoriesCountries[_countryCode], "Country has already signed the treaty");
        bool hasEveryDelegateSignedTheTreaty = allDelegatesSigned();
        if (hasEveryDelegateSignedTheTreaty == true) {
            signatoriesCountries[_countryCode] = true;
            emit TreatySigned(_countryCode);
        } else {
            string memory messageCountrySign = string.concat("Since All delegates have not signed yet, Treaty has not been Signed by: ", _countryCode);
            revert(messageCountrySign);
        }       
    }

    
    //Function to check if all delegates have signed
    function allDelegatesSigned() public view returns(bool) {
        uint delegatesSignedCount = 0;
        for (uint i = 0; i < delegates.length; i++) {
            if (delegateHasSigned(delegates[i])) {
                delegatesSignedCount += 1;
            }     
        }

        if (delegatesSignedCount == delegates.length && delegates.length != 0) {
            return true;
        } else {
            return false;
        }
    }

    //Function to check if a given name is a delegate
    function contains(string[] memory array, string memory nameGiven) public pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (keccak256(abi.encodePacked(array[i])) == keccak256(abi.encodePacked(nameGiven))) {
                return true;
            }
        }
        return false;
    }

   //Function to compare two string to see if they are equal (same)
    function compareStrings(string memory str1, string memory str2) public pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }


    //Function to sign treaty by each delegate
    function delegateSignTreaty(string memory _individualDelegateName, string memory _countryCode) public {
        bool givenDelegateNameIsLegit = contains(delegates, _individualDelegateName);
        bool validCountryCodeCorrespondence = compareStrings(signatoriesDelegatesToCountries[_individualDelegateName],_countryCode);
        
        if (validCountryCodeCorrespondence && givenDelegateNameIsLegit && bytes(_countryCode).length > 0) {
            require(!signatoriesDelegates[_individualDelegateName], "Delegate has already signed the treaty");
            signatoriesDelegates[_individualDelegateName] = true;
            emit TreatySignedByDelegate(_individualDelegateName);
        } else {
            revert("Delegate Name Given is not legitimate or the corresponding country code not supplied/invalid ");
        }
    }

    //Function to check if a delegated has signed the treaty
    function delegateHasSigned(string memory _theDelegateName) public view returns(bool)  {
        bool theGivenDelegateNameIsLegit = contains(delegates, _theDelegateName);
        if (theGivenDelegateNameIsLegit) {
             return signatoriesDelegates[_theDelegateName];
        } else {
            revert("Delegate Name Given is not legitimate");
        }
      
    }

    // Function to check if a country has signed the treaty
    function countryHasSigned(string memory _countryCode) public view returns (bool) {
        return signatoriesCountries[_countryCode];
    }
 
}
