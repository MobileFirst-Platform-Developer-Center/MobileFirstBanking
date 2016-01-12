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

import org.json.JSONObject;

import com.MobileFirstBanking.interfaces.ActivityNavigationInterface;
import com.MobileFirstBanking.listeners.MenuButtonClickListener;
import com.worklight.androidgap.api.WL;

import android.app.ProgressDialog;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.Animation.AnimationListener;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.RelativeLayout.LayoutParams;

public class ApplicationHybridActivityViewHelper {

	private ActivityNavigationInterface activityNavigation;
	
	private LayoutInflater inflater;
	private RelativeLayout containerLayout;

	private View actionBarView;
	private View menuBarView;
	private View menuView;
	
	private TextView pageTitleView;
	
	private Animation menuAnimationIn;
	private Animation menuAnimationOut;
	
	private ProgressDialog progressDialog;
	
	public ApplicationHybridActivityViewHelper(ActivityNavigationInterface navigationInterface) {
		this.activityNavigation = navigationInterface;
		
		containerLayout = new RelativeLayout(activityNavigation.activity());
		containerLayout.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
		
		
		inflater = (LayoutInflater) activityNavigation.activity().getLayoutInflater();
		
		
		// Menu Slide Animation
		menuAnimationIn = AnimationUtils.loadAnimation(activityNavigation.activity().getApplicationContext(), R.animator.menu_in);
		
		menuAnimationOut = AnimationUtils.loadAnimation(activityNavigation.activity().getApplicationContext(), R.animator.menu_out);
		menuAnimationOut.setAnimationListener(menuAnimationListener);
	}
	
	public RelativeLayout initLayout() {

		// show progress dialog
		progressDialog = new ProgressDialog(activityNavigation.activity());
		progressDialog.setMessage(activityNavigation.activity().getString(R.string.loading));
		progressDialog.setCancelable(false);
		progressDialog.setCanceledOnTouchOutside(false);
		progressDialog.setIndeterminate(true);
		progressDialog.show();

		setupMenu();
		
		LayoutParams menuViewLayoutParams = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
		menuViewLayoutParams.addRule(RelativeLayout.ALIGN_BASELINE);
		menuViewLayoutParams.addRule(RelativeLayout.ABOVE, R.id.menuStripLayout);
		menuViewLayoutParams.addRule(RelativeLayout.BELOW, R.id.actionBarLayout);
		
		containerLayout.addView(menuView, menuViewLayoutParams);
		
		setupMenuBar();
		
		LayoutParams menuBarViewLayoutParams = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
		menuBarViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);

		containerLayout.addView(menuBarView, menuBarViewLayoutParams);
		
		setupActionBar();

		LayoutParams actionBarLayoutParams = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
		actionBarLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
		
		int menubarHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 60, activityNavigation.activity().getResources().getDisplayMetrics());
		actionBarLayoutParams.height = menubarHeight;
		
		containerLayout.addView(actionBarView, actionBarLayoutParams);
		
		return containerLayout;
	}
	
	public void toggleMenu() {
		toggleMenu(false);
	}

	public void toggleMenu(final boolean hide) {
		if (!menuView.isShown() && hide) {
			return;
		}

		activityNavigation.activity().runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if (menuView.isShown() || hide) {
					menuView.startAnimation(menuAnimationOut);
				} else {
					menuView.setVisibility(View.VISIBLE);
					menuView.startAnimation(menuAnimationIn);
				}
			}
		});
	}

	public void showPageSecondary(final String title) {
		activityNavigation.activity().runOnUiThread(new Runnable() {
			@Override
			public void run() {
				menuBarView.setVisibility(View.VISIBLE);
				actionBarView.setVisibility(View.VISIBLE);
				
				pageTitleView.setText(title);
			}
		});
	}
	
	public void showPageDashboard() {
		activityNavigation.activity().runOnUiThread(new Runnable() {
			@Override
			public void run() {
				menuBarView.setVisibility(View.GONE);
				actionBarView.setVisibility(View.GONE);
				
				progressDialog.cancel();
			}
		});
	}
	
	private void setupMenuBar() {
		menuBarView = inflater.inflate(R.layout.menu_strip, null);
		menuBarView.setBackgroundColor(activityNavigation.activity().getResources().getColor(R.color.menu_bar_bg));
		menuBarView.setVisibility(View.GONE);

		menuBarView.findViewById(R.id.menuButton).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {

				WL.getInstance().sendActionToJS("menuButtonClicked", new JSONObject());
				
				toggleMenu();
			}

		});
	}
	
	private void setupActionBar() {
		actionBarView = inflater.inflate(R.layout.action_bar, null);
		actionBarView.setBackgroundColor(activityNavigation.activity().getResources().getColor(R.color.theme_blue));
		actionBarView.setVisibility(View.GONE);

		//  back button
		actionBarView.findViewById(R.id.buttonActionBack).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				activityNavigation.back();
			}
		});
		
		pageTitleView = (TextView)actionBarView.findViewById(R.id.actionBarTitle);
	}
	
	public void setupMenu() {
		menuView = inflater.inflate(R.layout.menu_layout, null);
		menuView.setBackgroundColor(activityNavigation.activity().getResources().getColor(R.color.menu_bg));
		menuView.setVisibility(View.GONE);

		ImageButton[] menuButtons = new ImageButton[6];

		menuButtons[0] = (ImageButton) menuView.findViewById(R.id.buttonAccounts);
		menuButtons[1] = (ImageButton) menuView.findViewById(R.id.buttonTransactions);
		menuButtons[2] = (ImageButton) menuView.findViewById(R.id.buttonLogout);
		menuButtons[3] = (ImageButton) menuView.findViewById(R.id.buttonDeposit);
		menuButtons[4] = (ImageButton) menuView.findViewById(R.id.buttonAppointments);
		menuButtons[5] = (ImageButton) menuView.findViewById(R.id.buttonFindAtm);
		
		MenuButtonClickListener listener = new MenuButtonClickListener(activityNavigation);

		for (ImageButton button : menuButtons) {
			button.setOnClickListener(listener);
		}
	}
	
	private AnimationListener menuAnimationListener = new AnimationListener() {

		@Override
		public void onAnimationEnd(Animation animation) {
			menuView.setVisibility(View.GONE);

		}

		@Override
		public void onAnimationRepeat(Animation animation) {}

		@Override
		public void onAnimationStart(Animation animation) {}
	};
}
