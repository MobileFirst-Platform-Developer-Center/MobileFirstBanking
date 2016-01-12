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
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.DialogInterface.OnClickListener;
import android.os.Bundle;
import android.os.Handler;
import android.provider.CalendarContract;
import android.provider.CalendarContract.Events;
import android.view.KeyEvent;
import android.view.Menu;
import android.widget.RelativeLayout.LayoutParams;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import org.apache.cordova.CordovaActivity;
import org.json.JSONException;
import org.json.JSONObject;

import com.MobileFirstBanking.interfaces.ActivityNavigationInterface;
import com.haibison.android.lockpattern.LockPatternActivity;
import com.worklight.androidgap.api.WL;
import com.worklight.androidgap.api.WLActionReceiver;
import com.worklight.androidgap.api.WLInitWebFrameworkResult;
import com.worklight.androidgap.api.WLInitWebFrameworkListener;

public class MobileFirstBanking extends CordovaActivity implements WLInitWebFrameworkListener, WLActionReceiver, ActivityNavigationInterface   {

	public static final String APPOINTMENT_NOTIFICATION = "appointmentNotification";
	private static final int APPOINTMENT_NOTIFICATION_ACTION = -1000;

	private static final int CONFIRM_PIN_CODE_ACTIVITY_START_CODE = 33333333;
	private static final int CREATE_CALENDAR_EVENT = 99999999;
	
	private boolean needsToShowAppointmentDetails = false;
	
	private ApplicationHybridActivityViewHelper hybridActivityHelper = null;

	private void proccessIntentAction(Intent intent) {
		Bundle extras = intent.getExtras();

		if (extras != null && extras.getBoolean(APPOINTMENT_NOTIFICATION)) {
			needsToShowAppointmentDetails = true;
		}
	}
	
	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);

		proccessIntentAction(intent);
	}
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		proccessIntentAction(getIntent());

		WL.createInstance(this);
		WL.getInstance().addActionReceiver(this);
		WL.getInstance().initializeWebFramework(getApplicationContext(), this);
		
		
		hybridActivityHelper = new ApplicationHybridActivityViewHelper(this);

	}


	@Override
	public boolean onPrepareOptionsMenu(Menu menu) {
		return true;
	}

	@Override
	public void navigateToPage(int id) {

		String pageButtonId = null;

		switch (id) {
			case R.id.buttonAccounts:
				pageButtonId = "PageAccount";
				break;
			case R.id.buttonTransactions:
				pageButtonId = "PageTransaction";
				break;
			case R.id.buttonDeposit:
				pageButtonId = "PageCheckDeposit";
				break;
			case R.id.buttonFindAtm:
				pageButtonId = "PageFindATM";
				break;
			case R.id.buttonAppointments:
				pageButtonId = "PageAppointment";
				break;
			case R.id.buttonLogout:
				pageButtonId = "Logout";
				break;
			case APPOINTMENT_NOTIFICATION_ACTION:
				pageButtonId = "PageAppointmentDetails";
				break;
			default:
				break;
		}

		try {
			JSONObject data = new JSONObject();
			data.put("buttonId", pageButtonId);
			WL.getInstance().sendActionToJS("nativeButtonClicked", data);

			hideMenuView();

		} catch (JSONException e) {}

	}
	
	@Override
	public void back() {
		dispatchKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_BACK));
		dispatchKeyEvent(new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_BACK));
	}

	@Override
	public Activity activity() {
		return this;
	}

	@Override
	public void onDestroy() {
		WL.getInstance().removeActionReceiver(this);
		super.onDestroy();
	}

	private void hideMenuView() {
		hybridActivityHelper.toggleMenu(true);
	}
	

	@Override
	public void onActionReceived(String action, JSONObject data) {

		if ("showDashboard".equals(action)) {
			hybridActivityHelper.showPageDashboard();
	            
			if(needsToShowAppointmentDetails) {
				navigateToPage(APPOINTMENT_NOTIFICATION_ACTION);
				needsToShowAppointmentDetails = false;
			}
	
		} else if("showSecondaryPage".equals(action)) {
			try {
				hybridActivityHelper.showPageSecondary(data.getString("title"));
			} catch (JSONException e) {}
		} else if ("createAppointment".equals(action)) {
			createCalendarAppointment(data);
		} else if ("getTransferPin".equals(action)) {
			processGetTransferPin();
		} else if ("LogoutButtonClicked".equals(action)) {
			processLogoutButtonClicked();
		} else if ("startActivityViewSpinner".equals(action)) {
			checkDepositProcessStart();
		} else if ("stopActivityViewSpinner".equals(action)) {
			checkDepositProcessStop();
		}

	}

	private void createCalendarAppointment(final JSONObject data) {

		runOnUiThread(new Runnable() {

			@Override
			public void run() {

				String date = data.optString("date", null);
				String time = data.optString("time", null);
				String location = data.optString("location", null);

				SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd kk:mm", Locale.US);

				try {
					Date parsedDate = dateFormat.parse(date + " " + time);

					Intent intent = new Intent(Intent.ACTION_INSERT);
					intent.setData(Events.CONTENT_URI);
					intent.putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, parsedDate.getTime());
					intent.putExtra(CalendarContract.EXTRA_EVENT_END_TIME, parsedDate.getTime() + 60 * 60 * 1000);
					intent.putExtra(Events.TITLE, getString(R.string.app_name) + " Appointment");
					intent.putExtra(Events.DESCRIPTION, "Discuss Loan Information");
					intent.putExtra(Events.EVENT_LOCATION, location);
					

					startActivityForResult(intent, CREATE_CALENDAR_EVENT);

				} catch (ParseException e) {}
			}

		});
	}

	private void createAppointmentNotification() {

		long when = System.currentTimeMillis() + 15000;

		Notification.Builder mBuilder = new Notification.Builder(this)
				.setSmallIcon(R.drawable.appointment_menu)
				.setContentTitle(getString(R.string.appointment_title))
				.setContentText(getString(R.string.appointment_description));

		mBuilder.setAutoCancel(true);
		mBuilder.setTicker(getString(R.string.appointment_title));
		mBuilder.setWhen(when);

		Intent viewIntent = new Intent(this, LaunchActivity.class);
		viewIntent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP);
		viewIntent.putExtra(APPOINTMENT_NOTIFICATION, true);

		PendingIntent viewPendingIntent = PendingIntent.getActivity(this, 0, viewIntent, 0);
		mBuilder.setContentIntent(viewPendingIntent);

		final Notification myNotification = mBuilder.build();

		final NotificationManager nm = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
		
		
		// delay notification for 5 seconds
	    Handler handler = new Handler(); 
	    handler.postDelayed(new Runnable() { 
	         public void run() { 
	        	 nm.notify(1, myNotification);
	         } 
	    }, 5000); 
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
			hideMenuView();
		}

		return super.onKeyDown(keyCode, event);
	}

	private void checkDepositProcessStart() {
		Notification.Builder notificationBuilder = new Notification.Builder(this);

		notificationBuilder.setSmallIcon(R.drawable.check_menu);
		notificationBuilder.setContentTitle(getString(R.string.check_deposit));
		notificationBuilder.setContentText(getString(R.string.uploading_checks));
		NotificationManager notifier = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
		notifier.notify(1, notificationBuilder.build());
	}

	private void checkDepositProcessStop() {
		NotificationManager notifier = (NotificationManager)getSystemService(Context.NOTIFICATION_SERVICE);
		notifier.cancel(1);
	}

	private void processGetTransferPin() {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {

				Intent intent = new Intent(LockPatternActivity.ACTION_COMPARE_PATTERN, null,
						MobileFirstBanking.this, LockPatternActivity.class);

				intent.putExtra("shouldAddBackground", true);

				intent.putExtra("logoImage", R.drawable.mfbanking_logo);

				intent.putExtra(LockPatternActivity.EXTRA_MAX_RETRIES, 3);
				intent.putExtra(LockPatternActivity.EXTRA_PATTERN, LockScreenCode.get());

				startActivityForResult(intent, CONFIRM_PIN_CODE_ACTIVITY_START_CODE);
			}
		});
	}

	private void processLogoutButtonClicked() {
		setResult(RESULT_OK);
		finish();
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
		super.onActivityResult(requestCode, resultCode, intent);

		switch (requestCode) {
		case CREATE_CALENDAR_EVENT:
			
			WL.getInstance().sendActionToJS("calendarEventReceived");

			createAppointmentNotification();

			break;
		case CONFIRM_PIN_CODE_ACTIVITY_START_CODE:
			if (resultCode == RESULT_OK) {
				WL.getInstance().sendActionToJS("transferPinValidationSuccess");
			} else {
				WL.getInstance().sendActionToJS("transferPinValidationFailure");
			}

			break;

		}
	}

	public void onInitWebFrameworkComplete(WLInitWebFrameworkResult result){
		if (result.getStatusCode() == WLInitWebFrameworkResult.SUCCESS) {
			super.loadUrl(WL.getInstance().getMainHtmlFilePath());
			
			addContentView(hybridActivityHelper.initLayout(), new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
		} else {
			handleWebFrameworkInitFailure(result);
		}
	}

	private void handleWebFrameworkInitFailure(WLInitWebFrameworkResult result){
		AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(this);
		alertDialogBuilder.setNegativeButton(R.string.close, new OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which){
				finish();
			}
		});

		alertDialogBuilder.setTitle(R.string.error);
		alertDialogBuilder.setMessage(result.getMessage());
		alertDialogBuilder.setCancelable(false).create().show();
	}
	
}
