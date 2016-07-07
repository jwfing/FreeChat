package com.leancloud.freechat;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.avos.avoscloud.AVException;
import com.avos.avoscloud.AVUser;
import com.avos.avoscloud.AVQuery;
import com.avos.avoscloud.FindCallback;
import com.leancloud.freechat.dummy.DummyContent;
import com.leancloud.freechat.dummy.DummyContent.DummyItem;

import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;
import java.util.ListIterator;

/**
 * A fragment representing a list of Items.
 * <p/>
 * Activities containing this fragment MUST implement the {@link OnContactItemInteractionListener}
 * interface.
 */
public class ContactFragment extends Fragment {
    private final static String TAG = ContactFragment.class.getSimpleName();
    private List<AVUser> mContacts;
    private MyContactsRecyclerViewAdapter mAdapter;
    private OnContactItemInteractionListener mListener;
    protected SwipeRefreshLayout mRefreshLayout;

    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public ContactFragment() {
    }

    // TODO: Customize parameter initialization
    @SuppressWarnings("unused")
    public static ContactFragment newInstance(int columnCount) {
        ContactFragment fragment = new ContactFragment();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onResume() {
        super.onResume();
        refreshContacts();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View fragment = inflater.inflate(R.layout.fragment_contact_list, container, false);
        mRefreshLayout = (SwipeRefreshLayout) fragment.findViewById(R.id.contact_fragment_srl_list);
        View view = fragment.findViewById(R.id.list);

        // Set the adapter
        if (view instanceof RecyclerView) {
            Context context = view.getContext();
            RecyclerView recyclerView = (RecyclerView) view;
            recyclerView.setLayoutManager(new LinearLayoutManager(context));
            mAdapter = new MyContactsRecyclerViewAdapter(new ArrayList<AVUser>(), mListener);
            recyclerView.setAdapter(mAdapter);
        }
        mRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                refreshContacts();
            }
        });
        return view;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnContactItemInteractionListener) {
            mListener = (OnContactItemInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnListFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    private void refreshContacts() {
        Log.i(TAG, "begin to refresh contacts.");
        AVQuery<AVUser> query = AVUser.getQuery();
        query.whereExists("email");
        query.orderByDescending("createdAt");
        query.setLimit(500);
        query.findInBackground(new FindCallback() {
            @Override
            public void done(List list, AVException e) {
                if (e != null) {
                    Log.e(TAG, "failed to retrieve users. cause: " + e.getMessage());
                } else {
                    Log.d(TAG, "retrieve user count: " + list.size());
                    mContacts = list;
                    mAdapter.updateItems(mContacts);
                    mAdapter.notifyDataSetChanged();
                }
                mRefreshLayout.setRefreshing(false);
            }
        });
    }
    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p/>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnContactItemInteractionListener {
        void onContactItemInteraction(AVUser item);
    }
}
