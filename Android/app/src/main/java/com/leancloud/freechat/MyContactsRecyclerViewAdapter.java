package com.leancloud.freechat;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.leancloud.freechat.ContactFragment.OnContactItemInteractionListener;

import java.util.List;

import com.avos.avoscloud.AVUser;

/**
 * {@link RecyclerView.Adapter} that can display a {@link AVUser} and makes a call to the
 * specified {@link OnContactItemInteractionListener}.
 * TODO: Replace the implementation with code for your data type.
 */
public class MyContactsRecyclerViewAdapter extends RecyclerView.Adapter<MyContactsRecyclerViewAdapter.ViewHolder> {

    private List<AVUser> mValues;
    private final OnContactItemInteractionListener mListener;

    public MyContactsRecyclerViewAdapter(List<AVUser> items, OnContactItemInteractionListener listener) {
        mValues = items;
        mListener = listener;
    }

    public void updateItems(List<AVUser> items) {
        mValues = items;
        super.notifyDataSetChanged();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.fragment_contact, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position) {
        holder.mItem = mValues.get(position);
        holder.mIdView.setText(new Integer(position).toString());
        holder.mContentView.setText(mValues.get(position).getEmail());

        holder.mView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (null != mListener) {
                    // Notify the active callbacks interface (the activity, if the
                    // fragment is attached to one) that an item has been selected.
                    mListener.onContactItemInteraction(holder.mItem);
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
        public AVUser mItem;

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
