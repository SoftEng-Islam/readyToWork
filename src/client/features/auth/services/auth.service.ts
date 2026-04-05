import { apolloClient } from '@/apollo';
import { gql } from '@apollo/client/core';
import type { IAuthResponse, IUserResponse } from 'shared/types/models';

export interface LoginCredentials {
	email: string;
	password: string;
}

export interface RegisterCredentials {
	username: string;
	email: string;
	password: string;
}

const REGISTER_MUTATION = gql`
  mutation Register($username: String!, $email: String!, $password: String!) {
    register(username: $username, email: $email, password: $password) {
      success
      token
      user {
        _id
        username
        email
        createdAt
        updatedAt
      }
      message
    }
  }
`;

const LOGIN_MUTATION = gql`
  mutation Login($email: String!, $password: String!) {
    login(email: $email, password: $password) {
      success
      token
      user {
        _id
        username
        email
        createdAt
        updatedAt
      }
      message
    }
  }
`;

const ME_QUERY = gql`
  query Me {
    me {
      _id
      username
      email
      createdAt
      updatedAt
    }
  }
`;

// Login user
export const loginUser = async (credentials: LoginCredentials): Promise<IAuthResponse> => {
	const { data } = await apolloClient.mutate<any>({
		mutation: LOGIN_MUTATION,
		variables: credentials
	});

	if (!data.login.success) {
		throw new Error(data.login.message || 'Login failed');
	}

	return {
		token: data.login.token,
		user: data.login.user
	};
};

// Register new user
export const registerUser = async (
	credentials: RegisterCredentials
): Promise<IAuthResponse> => {
	const { data } = await apolloClient.mutate<any>({
		mutation: REGISTER_MUTATION,
		variables: credentials
	});

	if (!data.register.success) {
		throw new Error(data.register.message || 'Registration failed');
	}

	return {
		token: data.register.token,
		user: data.register.user
	};
};

// Get current user
export const getCurrentUser = async (): Promise<{ user: IUserResponse }> => {
	const { data } = await apolloClient.query<any>({
		query: ME_QUERY,
		fetchPolicy: 'network-only'
	});
	return { user: data.me };
};
