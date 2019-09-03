/**
 * ProfileItem.java
 * 
 * Copyright 1997-2012 Integration Technologies Limited
 * All rights reserved.
 * 
 */
package pumpdemo.gradeprofile;

import itl.enabler.api.Profile;

/**
 * Profile items to show in Grade pricing and profiles dialog
 * 
 */
public class ProfileItem {

	private Profile profile;

	public ProfileItem(Profile profile) {
		this.profile = profile;
	}

	/**
	 * (non-Javadoc) return profile name
	 */
	@Override
	public String toString() {
		return profile.getName();
	}

	public Profile getProfile() {
		return profile;
	}
}
