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
component extends="BaseService" accessors="true" output="false" {

	property name="tagProxyService" type="Slatwall.com.service.TagProxyService";
	property name="requestCacheService" type="Slatwall.com.service.RequestCacheService";
	property name="accountService" type="Slatwall.com.service.AccountService";
	
	public void function confirmSession() {
		getCurrent();
	}
	
	public any function getCurrent() {
		if(!getRequestCacheService().keyExists("currentSession")) {
			getRequestCacheService().setValue("currentSession", getPropperSession());
		}
		return getRequestCacheService().getValue("currentSession");
	}
	
	public any function getCurrentAccount() {
		if(getRequestCacheService().keyExists("currentSession")) {
			return getRequestCacheService().getValue("currentSession").getAccount();
		} else {
			return JavaCast("null", "");
		}
	}
	
	private any function getPropperSession() {
		// Figure out the appropriate session ID and create a new one if necessary
		if(!isDefined('session.slatwall.sessionID')) {
			if(structKeyExists(cookie, "slatwallSessionID")) {
				session.slatwall.sessionID = cookie.slatwallSessionID;
			} else {
				session.slatwall.sessionID = "";
			}
		}

		// Load Session
		var currentSession = this.getSession(session.slatwall.sessionID);
		
		// If No Session in Database create a new one.
		if(isNull(currentSession)) {
			currentSession = this.newSession();
		}
		
		// Setup account here
		var muraUser = getRequestCacheService().getValue("muraScope").currentUser();
		
		if(muraUser.isLoggedIn()) {
			// Load the account
			var slatwallAccount = getAccountService().getAccountByMuraUser(muraUser);
			
			// Update the account with any changes in the mura user
			slatwallAccount = getAccountService().updateAccountFromMuraUser(slatwallAccount, muraUser);
			
			// Set the account in the current session
			currentSession.setAccount(slatwallAccount);
			
			// Make sure that the account on the current order is whoever is logged in
			if(!isNull(currentSession.getOrder()) && !currentSession.getOrder().isNew()) {
				currentSession.getOrder().setAccount(slatwallAccount);
			}
		} else {
			// Remove any account associated with the session
			currentSession.removeAccount();
		}
		
		// Save the session
		save(currentSession);
		
		// Save session ID in the session Scope & cookie scope for next request
		session.slatwall.sessionID = currentSession.getSessionID();
		getTagProxyService().cfcookie(name="slatwallSessionID", value=currentSession.getSessionID(), expires="never");
		
		return currentSession;
	}
	
	public void function setValue(required string property, required any value) {
		if(!arguments.property == "sessionID") {
			session.slatwall[arguments.property] = arguments.value;	
		}
	}
	
	public any function getValue(required string property, any defaultValue) {
		if(structKeyExists(session.slatwall,arguments.property)) {
			return session.slatwall[arguments.property];
		} else if (structKeyExists(arguments, "defaultValue")) {
			return arguments.defaultValue;
		} else {
			return javaCast("null","");
		}
	}
	
	public any function hasValue(required string property) {
		return structKeyExists(session.slatwall,arguments.property);
	}
	
	public void function removeValue(required string property) {
		structDelete(session.slatwall,arguments.property);
	}
	
}
