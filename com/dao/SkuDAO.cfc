<!---

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

--->
<cfcomponent extends="BaseDAO">
	
	<cfscript>
	// returns product skus which matches ALL options (list of optionIDs) that are passed in
	public any function getSkusBySelectedOptions(required string selectedOptions, string productID) {
		var params = [];
		var hql = "select distinct sku from SlatwallSku as sku 
					inner join sku.options as opt 
					where 
					0 = 0 ";
		for(var i=1; i<=listLen(arguments.selectedOptions); i++) {
			var thisOptionID = listGetat(arguments.selectedOptions,i);
			hql &= "and exists (
						from SlatwallOption o
						join o.skus s where s.id = sku.id
						and o.optionID = ?
					) ";
			arrayAppend(params,thisOptionID);
		}
		// if product ID is passed in, limit query to the product
		if(structKeyExists(arguments,"productID")) {
			hql &= "and sku.product.id = ?";
			arrayAppend(params,arguments.productID);	
		}
		return ormExecuteQuery(hql,params);
	}
	</cfscript>

	<cffunction name="getSortedProductSkusID">
		<cfargument name="productID" type="string" required="true" />
		
		<cfset var sorted = "" />
		<cfif application.configBean.getDbType() eq "MySQL">
			<cfset local.castAs = "decimal" />
		<cfelse>
			<cfset local.castAs = "float" />
		</cfif>
		
		<!--- TODO: test to see if this query works with DB's other than MSSQL and MySQL --->
		<cfquery name="sorted" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			SELECT
				SlatwallSku.skuID
			FROM
				SlatwallSku
			  INNER JOIN
				SlatwallSkuOption on SlatwallSku.skuID = SlatwallSkuOption.skuID
			  INNER JOIN
				SlatwallOption on SlatwallSkuOption.optionID = SlatwallOption.optionID
			  INNER JOIN
				SlatwallOptionGroup on SlatwallOption.optionGroupID = SlatwallOptionGroup.optionGroupID
			WHERE
				SlatwallSku.productID = <cfqueryparam value="#arguments.productID#" cfsqltype="cf_sql_varchar" />
			GROUP BY
				SlatwallSku.skuID, SlatwallSku.skuCode
			ORDER BY
				<!--- This formula came with help from Blar Gibb and Jacob West... their formula was better with varying max optoinSortOrder and optionGroupSortOrder... but it wasn't possible with SQL, well at least I couldn't figure it out -GM --->
				sum(
					CAST( SlatwallOption.sortOrder as #local.castAs# ) * 
					POWER( CAST(10000 as #local.castAs#), CAST((20 - SlatwallOptionGroup.sortOrder) as #local.castAs# ) )
				)
		</cfquery>
		
		<cfreturn sorted />
	</cffunction>
	
</cfcomponent>