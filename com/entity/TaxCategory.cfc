/*

    Slatwall - An e-commerce plugin for Mura CMS
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

*/
component displayname="Tax Category" entityname="SlatwallTaxCategory" table="SlatwallTaxCategory" persistent="true" output="false" accessors="true" extends="BaseEntity" {
	
	// Persistent Properties
	property name="taxCategoryID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="taxCategoryName" ormtype="string";
	
	property name="taxCategoryRates" singularname="taxCategoryRate" cfc="TaxCategoryRate" fieldtype="one-to-many" inverse="true" cascade="all-delete-orphan";
	
	// Audit properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID" constrained="false";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID" constrained="false";
	
	public any function init() {
		if(isNull(getTaxCategoryRates())) {
			setTaxCategoryRates(arrayNew(1));
		}
		
		return super.init();
	}
	
	/******* Association management methods for bidirectional relationships **************/
	
	// Tax Category Rates
	public void function addTaxCategoryRate(required TaxCategoryRate taxCategoryRate) {
	   arguments.taxCategoryRate.setTaxCategory(this);
	}
	
	public void function removeTaxCategoryRate(required TaxCategoryRate taxCategoryRate) {
	   arguments.taxCategoryRate.removeTaxCategory(this);
	}
	
	/******* END Association management methods for bidirectional relationships **************/
}
