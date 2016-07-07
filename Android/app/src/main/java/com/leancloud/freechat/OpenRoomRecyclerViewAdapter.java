package com.leancloud.freechat;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.avos.avoscloud.im.v2.AVIMConversation;
import com.leancloud.freechat.OpenRoomFragment.OnRoomItemInteractionListener;
import com.leancloud.freechat.dummy.DummyContent.DummyItem;

import java.util.List;

/**
 * {@link RecyclerView.Adapter} that can display a {@link DummyItem} and makes a call to the
 * specified {@link OnRoomItemInteractionListener}.
 * TODO: Replace the implementation with code for your data type.
 */
public class OpenRoomRecyclerViewAdapter extends RecyclerView.Adapter<OpenRoomRecyclerViewAdapter.ViewHolder> {

    private List<AVIMConversation> mValues;
    private final OnRoomItemInteractionListener mListener;

    public OpenRoomRecyclerViewAdapter(List<AVIMConversation> items, OnRoomItemInteractionListener listener) {
        mValues = items;
        mListener = listener;
    }

    public void updateItems(List<AVIMConversation> items) {
        if (null != items) {
            mValues = items;
        }
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.fragment_openroom, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position) {
        holder.mItem = mValues.get(position);
        holder.mIdView.setText(new Integer(position).toString());
        holder.mContentView.setText(mValues.get(position).getName());

        holder.mView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (null != mListener) {
                    // Notify the active callbacks interface (the activity, if the
                    // fragment is attached to one) that an item has been selected.
                    mListener.onRoomInteraction(holder.mItem);
                }
            }
        });
    }

    @Override
    public int getItemCount() {
        return mValues.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        public final View mView;
        public final TextView mIdView;
        public final TextView mContentView;
        public AVIMConversation mItem;

        public ViewHolder(View view) {
            super(view);
            mView = view;
            mIdView = (TextView) view.findViewById(R.id.id);
            mContentView = (TextView) view.findViewById(R.id.content);
        }

        @Override
        public String toString() {
            return super.toString() + " '" + mContentView.getText() + "'";
        }
    }
}
