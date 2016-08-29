public with sharing class ShopCtrl {

	public static final String PARAMETER_ID = 'Id';
	public Id recordId { get;set; }
	public String searchField { get;set; }
	public Integer firstRecord { get;set; }
	public Integer recordsAtTime { get;set; }
	public Integer recordsCount { get;set; }
	public Integer currentPage { get;set; }
	public String pageNumber { get;set; }
	public String errorMessage { get;set; }
	public String pageDisplay { get;set; }
	public String productName { get;set; }
	//Dynamic SOQL to enable the search feature
	public List<Product__c> products { get {
			String search = '%'+searchField+'%';
			String query = 'SELECT Id, Name__c, Cost__c, Description__c, Title__c, ImageName__c, ImageURL__c, Amount__c ' +
																 'FROM Product__c WHERE RecordTypeId = :recId';
			Id recId = [SELECT Id FROM RecordType WHERE Name = 'Made' LIMIT 1].Id;
			if (searchField != null && searchField != '') {
				query += ' AND Name__c LIKE :search';
			}
			query += ' ORDER BY Name LIMIT 10000';
			List<Product__c> searchQuery = Database.query(query);
			this.recordsCount = searchQuery.size();
			System.debug(query + 'query');
			System.debug(searchField + 'searchField');
			return searchQuery;
		}
		set;

	}

	public Set<SelectOption> selectOptions { get {
        	return new Set<SelectOption>{
        							new SelectOption('5','5'),
        							new SelectOption('10','10'),
					            	new SelectOption('20','20'),
					            	new SelectOption('50', '50')};
		} set;
	}

	public ShopCtrl() {
		this.firstRecord = 0;
		this.recordsAtTime = 5;
		this.recordsCount = 0;
		this.currentPage = 1;
		this.pageNumber = string.valueof(this.currentPage);
	}

	//Go to the product details vpf
	public PageReference productDetails() {
		PageReference result = Page.ProductDetails;
		result.getParameters().put(PARAMETER_ID, recordId);
		return result;
	}

	//Go to the new order vfp
	public PageReference newOrder() {
		PageReference result = Page.NewOrder;
        result.getParameters().put(PARAMETER_ID, recordId);
        return result;
	}

	//Go to the next page of pageBlockTable
	public void nextPage() {
		//If currentPage is lower than the total amount of pages, turn the page
		if (this.currentPage < getPageCalc()) {
			this.firstRecord += this.recordsAtTime;
			this.currentPage = this.currentPage + 1;
		}
		System.debug(firstRecord + 'firstRecord');
	}

	//Return to the previous page of pageBlockTable
	public void previousPage() {
		if (this.firstRecord > 0) {
			this.firstRecord -= this.recordsAtTime;
			this.currentPage = this.currentPage - 1;
		}
	}

	//Calculate the total number of pages
	public Integer getPageCalc() {
		Integer result;
		result = this.recordsCount / this.recordsAtTime;
		result++;
		this.pageDisplay = string.valueof(result);
		System.debug(result + 'pageCalc');
		System.debug(pageDisplay + 'pageDisplay');
		return result;
	}

	//When another selectOption is selected, refresh the pageBlockTable
	public void refreshTable() {
		this.firstRecord = 0;
		System.debug(recordsAtTime + 'recordsAtTime');
		System.debug(recordsCount + 'recordsCount');
	}

	//Go to a certain page entered by the user
	public void moveToPage() {
		//pageNumber must be numeric, higher than zero, not a blank value and must not exceed a total number of pages
		if (this.pageNumber.isnumeric() 
			&& string.isblank(this.pageNumber) == false 
			&& integer.valueof(this.pageNumber) > 0 
			&& integer.valueof(this.pageNumber) <= getPageCalc()) {
				this.currentPage = integer.valueof(this.pageNumber);
				this.firstRecord = this.recordsAtTime * (this.currentPage - 1);
				this.errorMessage = '';
		}
		else {
			this.errorMessage = Label.IncorrectInput;
		}
	}

	@RemoteAction
	public static List<Product__c> getProduct(String productName) {
		List<Product__c> searchProduct = [SELECT Id, 
								Name__c, 
								Cost__c, 
								Description__c, 
								Title__c, 
								ImageURL__c, 
								Amount__c  FROM Product__c WHERE Name__c = :productName LIMIT 10000];
		return searchProduct;
	}
}