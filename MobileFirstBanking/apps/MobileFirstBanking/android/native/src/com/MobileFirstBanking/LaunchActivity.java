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


import android.app.Activity;
import android.app.AlertDialog;

import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.os.Bundle;

import com.haibison.android.lockpattern.LockPatternActivity;
import com.worklight.androidgap.api.WL;
import com.worklight.androidgap.api.WLInitWebFrameworkListener;
import com.worklight.androidgap.api.WLInitWebFrameworkResult;



public class LaunchActivity extends Activity implements WLInitWebFrameworkListener {

	private static int LOGIN_PATTERN_ACTIVITY_START_CODE = 111111111;
	private static int HYBRID_ACTIVITY_START_CODE = 222222222;
	
	private Intent hybridActivityIntent = null;

	private void proccessIntentAction(Intent intent, Bundle bundle) {
		Bundle extras = intent.getExtras();
		boolean pendingAppointment = false;
		
		if (bundle == null) {
			if(extras != null && extras.getBoolean(MobileFirstBanking.APPOINTMENT_NOTIFICATION)) {
				pendingAppointment = true;
			}
		} else if((Boolean) bundle.getSerializable(MobileFirstBanking.APPOINTMENT_NOTIFICATION)) {
			pendingAppointment = true;
		}
		
		if(pendingAppointment) {
			hybridActivityIntent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
			hybridActivityIntent.putExtra(MobileFirstBanking.APPOINTMENT_NOTIFICATION, true);
		}
	}
	
	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);

		proccessIntentAction(intent, intent.getExtras());
	}

	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.authentication_layout);
		
		hybridActivityIntent = new Intent(this, MobileFirstBanking.class);
		proccessIntentAction(getIntent(), savedInstanceState);

		WL.createInstance(this);
		WL.getInstance().initializeWebFramework(getApplicationContext(), this);

		startLockPatternActivity();

	}

	private void startLockPatternActivity() {
		Intent intent = new Intent(LockPatternActivity.ACTION_COMPARE_PATTERN, null, LaunchActivity.this, LockPatternActivity.class);
		
		intent.putExtra("logoImage", R.drawable.mfbanking_logo);
		
		intent.putExtra(LockPatternActivity.EXTRA_PATTERN, LockScreenCode.get());

		startActivityForResult(intent, LOGIN_PATTERN_ACTIVITY_START_CODE);
	}

	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == LOGIN_PATTERN_ACTIVITY_START_CODE) {
			processReturnFromLoginPatternActivity(resultCode);
		} else if (requestCode == HYBRID_ACTIVITY_START_CODE) {
//			hybridActivityIntent.removeExtra(HybridActivity.APPOINTMENT_NOTIFICATION);
			startLockPatternActivity();
		}
	}

	private void processReturnFromLoginPatternActivity(int resultCode) {
		switch (resultCode) {
		case RESULT_OK:
			startActivityForResult(hybridActivityIntent, HYBRID_ACTIVITY_START_CODE);
			break;
		case RESULT_CANCELED:
		case LockPatternActivity.RESULT_FAILED:
		case LockPatternActivity.RESULT_FORGOT_PATTERN:
			finish();
			break;
		}
	}

	/**
	 * The IBM Worklight web framework calls this method after its
	 * initialization is complete and web resources are ready to be used.
	 */
	public void onInitWebFrameworkComplete(WLInitWebFrameworkResult result) {
		if (result.getStatusCode() == WLInitWebFrameworkResult.SUCCESS) {
			
		} else {
			handleWebFrameworkInitFailure(result);
		}
	}

	private void handleWebFrameworkInitFailure(WLInitWebFrameworkResult result) {
		AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(this);
		
		alertDialogBuilder.setNegativeButton(R.string.close, new OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				finish();
			}
		});

		alertDialogBuilder.setTitle(R.string.error);
		alertDialogBuilder.setMessage(result.getMessage());
		alertDialogBuilder.setCancelable(false).create().show();
	}
}
