/*
 *  © Copyright 2015 IBM Corp.
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

package com.MobileFirstBanking;

public class LockScreenCode {
	private static final char[] savedPattern = {'f','1','d','e','3','0','f','e','e','f','7','1','1','c','0','1','8','e','a','9','9','8','7','c','0','e','1','7','1','6','8','d','b','9','d','6','a','b','5','3'};
	public static char[] get(){
		return savedPattern;
	}
}