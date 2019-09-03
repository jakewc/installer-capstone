/**
 * GradeItem.java
 * 
 * Copyright 1997-2012 Integration Technologies Limited
 * All rights reserved.
 * 
 */
package pumpdemo.gradeprofile;

import itl.enabler.api.Grade;

/**
 * Grade items to show in Grade pricing and Profiles dialog
 * 
 */
public class GradeItem {

	private Grade grade;

	public GradeItem(Grade grade) {
		this.grade = grade;
	}

	/**
	 * return grade name
	 */
	@Override
	public String toString() {
		return grade.getName();
	}

	public Grade getGrade() {
		return grade;
	}
}
