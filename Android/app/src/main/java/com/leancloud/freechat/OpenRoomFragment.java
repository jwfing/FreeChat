package com.leancloud.freechat;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.avos.avoscloud.im.v2.AVIMConversation;
import com.avos.avoscloud.im.v2.AVIMConversationQuery;
import com.avos.avoscloud.im.v2.AVIMException;
import com.avos.avoscloud.im.v2.callback.AVIMConversationQueryCallback;
import com.leancloud.freechat.dummy.DummyContent;
import com.leancloud.freechat.dummy.DummyContent.DummyItem;

import java.util.ArrayList;
import java.util.List;

import cn.leancloud.chatkit.LCChatKit;

/**
 * A fragment representing a list of Items.
 * <p/>
 * Activities containing this fragment MUST implement the {@link OnRoomItemInteractionListener}
 * interface.
 */
public class OpenRoomFragment extends Fragment {
    private static final String TAG = OpenRoomFragment.class.getSimpleName();
    private OnRoomItemInteractionListener mListener;
    private List<AVIMConversation> mConversations;
    private OpenRoomRecyclerViewAdapter mAdapter;

    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public OpenRoomFragment() {
    }

    // TODO: Customize parameter initialization
    @SuppressWarnings("unused")
    public static OpenRoomFragment newInstance(int columnCount) {
        OpenRoomFragment fragment = new OpenRoomFragment();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    public void onResume() {
        super.onResume();
        retrieveOpenRooms();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_openroom_list, container, false);

        // Set the adapter
        if (view instanceof RecyclerView) {
            mAdapter = new OpenRoomRecyclerViewAdapter(new ArrayList<AVIMConversation>(), mListener);
            Context context = view.getContext();
            RecyclerView recyclerView = (RecyclerView) view;
            recyclerView.setLayoutManager(new LinearLayoutManager(context));
            recyclerView.setAdapter(mAdapter);
        }
        return view;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnRoomItemInteractionListener) {
            mListener = (OnRoomItemInteractionListener) context;
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

    private void retrieveOpenRooms() {
        AVIMConversationQuery query = LCChatKit.getInstance().getClient().getQuery();
        query.whereEqualTo("tr", true);
        query.findInBackground(new AVIMConversationQueryCallback() {
            @Override
            public void done(List<AVIMConversation> list, AVIMException e) {
                if (e != null) {
                    Log.w(TAG, e.getMessage());
                } else {
                    Log.i(TAG, "retrieve open room count: " + list.size());
                    mConversations = list;
                    mAdapter.updateItems(mConversations);
                    mAdapter.notifyDataSetChanged();
                }
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
    public interface OnRoomItemInteractionListener {
        void onRoomInteraction(AVIMConversation item);
    }
}
